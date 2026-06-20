<?php

namespace Tests\Feature;

use App\Models\Program;
use App\Models\Request as ServiceRequest;
use App\Models\RequestType;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use App\Models\Payment;
use App\Enums\RequestStatusEnum;
use App\Enums\StudentStatusEnum;
use App\Enums\PaymentStatusEnum;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;
use Carbon\Carbon;

class BusinessWorkflowTest extends TestCase
{
    use RefreshDatabase;

    private $studentUser;
    private $student;
    private $suspensionType;
    private $reEnrollmentType;
    private $semester;
    private $affairsUser;
    private $accountantUser;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');

        // Setup Roles and Permissions (Simulate DatabaseSeeder structure)
        $this->artisan('db:seed', ['--class' => 'RoleAndPermissionSeeder']);

        // Create Users
        $this->studentUser = User::factory()->create(['role' => 'student']);
        $this->studentUser->assignRole('student');

        $this->affairsUser = User::factory()->create(['role' => 'student_affairs']);
        $this->affairsUser->assignRole('student_affairs');

        $this->accountantUser = User::factory()->create(['role' => 'accountant']);
        $this->accountantUser->assignRole('accountant');

        $program = Program::factory()->create();

        $this->student = Student::factory()->create([
            'user_id' => $this->studentUser->id,
            'program_id' => $program->id,
            'current_level' => 2,
            'status' => StudentStatusEnum::ACTIVE,
        ]);

        $this->semester = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => Carbon::now()->addDays(20)->toDateString(),
        ]);

        // Request Types
        $this->suspensionType = RequestType::create([
            'name' => 'تأجيل دراسة',
            'slug' => 'tagyl-dras',
            'target_role' => 'student_affairs',
            'is_active' => true,
            'price' => 0.00,
        ]);

        $this->reEnrollmentType = RequestType::create([
            'name' => 'إعادة قيد',
            'slug' => 're_enrollment',
            'target_role' => 'student_affairs',
            'is_active' => true,
            'price' => 0.00,
        ]);
    }

    public function test_suspension_workflow_e2e()
    {
        // 1. Student submits a suspension request
        $file = UploadedFile::fake()->create('document.pdf', 100, 'application/pdf');
        $response = $this->actingAs($this->studentUser)->postJson('/api/student/service-requests', [
            'request_type_id' => $this->suspensionType->id,
            'form_data' => [
                'suspension_reason' => 'Medical reasons',
                'start_semester_id' => $this->semester->id,
                'duration_semesters' => 1,
            ],
            'attachments' => [$file],
        ]);

        $response->assertStatus(201);
        $requestId = $response->json('data.id');

        // Verify request starts as pending
        $request = ServiceRequest::findOrFail($requestId);
        $this->assertEquals(RequestStatusEnum::PENDING, $request->status);

        // 2. Verify it does NOT show to Student Affairs (since it is still pending and needs payment verification)
        $responseAffairs = $this->actingAs($this->affairsUser)->getJson('/api/staff/requests');
        $responseAffairs->assertStatus(200);
        $requestsIdsAffairs = collect($responseAffairs->json('data'))->pluck('id')->toArray();
        $this->assertNotContains($requestId, $requestsIdsAffairs);

        // Also check unified-requests endpoint
        $responseUnifiedAffairs = $this->actingAs($this->affairsUser)->getJson('/api/admin/unified-requests');
        $responseUnifiedAffairs->assertStatus(200);
        $unifiedIdsAffairs = collect($responseUnifiedAffairs->json('data'))->pluck('id')->toArray();
        $this->assertNotContains($requestId, $unifiedIdsAffairs);

        // 3. Verify it shows to Accountant (only pending ones)
        $responseAccountant = $this->actingAs($this->accountantUser)->getJson('/api/staff/requests');
        $responseAccountant->assertStatus(200);
        $requestsIdsAccountant = collect($responseAccountant->json('data'))->pluck('id')->toArray();
        $this->assertContains($requestId, $requestsIdsAccountant);

        // 4. Student submits a payment receipt referencing the request
        $file = UploadedFile::fake()->create('receipt.png', 100, 'image/png');
        $responsePay = $this->actingAs($this->studentUser)->postJson('/api/student/payments', [
            'amount' => 100.00,
            'purpose' => 'رسوم التأجيل',
            'receipt_image' => $file,
            'ref_number' => 'REF-' . $requestId,
        ]);
        $responsePay->assertStatus(201);
        $paymentId = $responsePay->json('data.id');

        // 5. Accountant verifies the payment
        $responseVerify = $this->actingAs($this->accountantUser)->putJson("/api/staff/payments/{$paymentId}/verify");
        $responseVerify->assertStatus(200);

        // Verify request automatically transitions to RATIFIED
        $request->refresh();
        $this->assertEquals(RequestStatusEnum::RATIFIED, $request->status);

        // 6. Verify request now shows to Student Affairs
        $responseAffairsAfter = $this->actingAs($this->affairsUser)->getJson('/api/staff/requests');
        $requestsIdsAffairsAfter = collect($responseAffairsAfter->json('data'))->pluck('id')->toArray();
        $this->assertContains($requestId, $requestsIdsAffairsAfter);

        // 7. Student Affairs approves the request
        // First verify they cannot approve before accountant ratification (not needed here since already ratified, but let's test block logic by creating another request)
        $newRequest = ServiceRequest::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->suspensionType->id,
            'status' => RequestStatusEnum::PENDING,
            'description' => 'Unratified request',
        ]);
        // Try to approve unratified request
        $responseApproveFail = $this->actingAs($this->affairsUser)->patchJson("/api/staff/requests/{$newRequest->id}/status", [
            'status' => 'approved',
            'response_message' => 'Approved',
        ]);
        $responseApproveFail->assertStatus(400);
        $this->assertStringContainsString('لا يمكن الموافقة النهائية قبل تصديق المحاسب.', $responseApproveFail->json('error'));

        // Now approve the ratified request
        $responseApprove = $this->actingAs($this->affairsUser)->patchJson("/api/staff/requests/{$requestId}/status", [
            'status' => 'approved',
            'response_message' => 'Approved temporary suspension',
        ]);
        $responseApprove->assertStatus(200);

        // Verify request status is approved and student is suspended
        $request->refresh();
        $this->student->refresh();
        $this->assertEquals(RequestStatusEnum::APPROVED, $request->status);
        $this->assertEquals(StudentStatusEnum::SUSPENDED, $this->student->status);
    }

    public function test_re_enrollment_workflow_e2e()
    {
        // Setup suspended student
        $this->student->update(['status' => StudentStatusEnum::SUSPENDED]);

        // 1. Student submits a re-enrollment request
        $suspensionForm = UploadedFile::fake()->create('suspension_form.pdf', 100, 'application/pdf');
        $universityId = UploadedFile::fake()->create('university_id.pdf', 100, 'application/pdf');
        $response = $this->actingAs($this->studentUser)->postJson('/api/student/re-enrollment', [
            'request_type_id' => $this->reEnrollmentType->id,
            'suspension_form' => $suspensionForm,
            'university_id' => $universityId,
            'description' => 'طلب إعادة قيد',
        ]);
        $response->assertStatus(201);
        $requestId = $response->json('data.id');

        // Verify request starts as pending
        $request = ServiceRequest::findOrFail($requestId);
        $this->assertEquals(RequestStatusEnum::PENDING, $request->status);

        // 2. Verify it does NOT show to Student Affairs (since it is pending)
        $responseAffairs = $this->actingAs($this->affairsUser)->getJson('/api/staff/requests');
        $requestsIdsAffairs = collect($responseAffairs->json('data'))->pluck('id')->toArray();
        $this->assertNotContains($requestId, $requestsIdsAffairs);

        // 3. Accountant ratifies re-enrollment fees
        $responseRatifyFee = $this->actingAs($this->accountantUser)->putJson("/api/staff/re-enrollment/{$requestId}/ratify", [
            'university_fees' => 1500.00,
            'other_fees' => 100.00,
        ]);
        $responseRatifyFee->assertStatus(200);

        // Student Affairs ratifies academic details
        $responseRatifyAcad = $this->actingAs($this->affairsUser)->putJson("/api/staff/re-enrollment/{$requestId}/ratify", [
            'major' => 'علوم الحاسوب',
            'level' => 2,
            'batch' => '2024',
            'academic_year' => '2026/2027',
        ]);
        $responseRatifyAcad->assertStatus(200);

        // 4. Student submits a payment receipt referencing the request
        $file = UploadedFile::fake()->create('receipt.png', 100, 'image/png');
        $responsePay = $this->actingAs($this->studentUser)->postJson('/api/student/payments', [
            'amount' => 1600.00,
            'purpose' => 'رسوم إعادة قيد',
            'receipt_image' => $file,
            'ref_number' => 'REF-' . $requestId,
        ]);
        $responsePay->assertStatus(201);
        $paymentId = $responsePay->json('data.id');

        // 5. Accountant verifies the payment
        $responseVerify = $this->actingAs($this->accountantUser)->putJson("/api/staff/payments/{$paymentId}/verify");
        $responseVerify->assertStatus(200);

        // Request transitions to RATIFIED and becomes visible to Student Affairs
        $request->refresh();
        $this->assertEquals(RequestStatusEnum::RATIFIED, $request->status);

        $responseAffairsAfter = $this->actingAs($this->affairsUser)->getJson('/api/staff/requests');
        $requestsIdsAffairsAfter = collect($responseAffairsAfter->json('data'))->pluck('id')->toArray();
        $this->assertContains($requestId, $requestsIdsAffairsAfter);

        // 6. Student Affairs approves re-enrollment request
        $responseApprove = $this->actingAs($this->affairsUser)->putJson("/api/staff/re-enrollment/{$requestId}/approve");
        $responseApprove->assertStatus(200);

        // Verify request status is approved and student is active
        $request->refresh();
        $this->student->refresh();
        $this->assertEquals(RequestStatusEnum::APPROVED, $request->status);
        $this->assertEquals(StudentStatusEnum::ACTIVE, $this->student->status);
    }
}
