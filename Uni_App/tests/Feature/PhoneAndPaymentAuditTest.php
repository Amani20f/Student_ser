<?php

namespace Tests\Feature;

use App\Models\Program;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use App\Models\Request as ServiceRequest;
use App\Models\RequestType;
use App\Models\Appeal;
use App\Enums\StudentStatusEnum;
use App\Enums\PaymentStatusEnum;
use App\Enums\AppealStatusEnum;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PhoneAndPaymentAuditTest extends TestCase
{
    use RefreshDatabase;

    private $studentUser;
    private $student;
    private $semester;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        $this->artisan('db:seed', ['--class' => 'RoleAndPermissionSeeder']);

        $this->studentUser = User::factory()->create(['role' => 'student']);
        $this->studentUser->assignRole('student');

        $program = Program::factory()->create();

        $this->student = Student::factory()->create([
            'user_id' => $this->studentUser->id,
            'program_id' => $program->id,
            'current_level' => 2,
            'status' => StudentStatusEnum::ACTIVE,
            'phone' => '1234567890',
        ]);

        $this->semester = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => '2026-12-15',
        ]);
    }

    public function test_phone_number_accepts_and_normalizes_arabic_digits_on_update()
    {
        // Arabic digits for 0501234567: ٠٥٠١٢٣٤٥٦٧
        $arabicPhone = '٠٥٠١٢٣٤٥٦٧';
        
        $response = $this->actingAs($this->studentUser)->putJson('/api/student/profile', [
            'name' => $this->studentUser->name,
            'email' => $this->studentUser->email,
            'phone' => $arabicPhone,
            'national_id' => $this->student->national_id,
        ]);

        $response->assertStatus(200);
        $this->student->refresh();
        // Assert it normalized the phone to English digits
        $this->assertEquals('0501234567', $this->student->phone);
    }

    public function test_phone_number_fails_when_length_exceeds_15_digits()
    {
        $tooLongPhone = '1234567890123456'; // 16 digits
        
        $response = $this->actingAs($this->studentUser)->putJson('/api/student/profile', [
            'name' => $this->studentUser->name,
            'email' => $this->studentUser->email,
            'phone' => $tooLongPhone,
            'national_id' => $this->student->national_id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors('phone');
    }

    public function test_phone_number_fails_when_length_is_less_than_8_digits()
    {
        $tooShortPhone = '1234567'; // 7 digits
        
        $response = $this->actingAs($this->studentUser)->putJson('/api/student/profile', [
            'name' => $this->studentUser->name,
            'email' => $this->studentUser->email,
            'phone' => $tooShortPhone,
            'national_id' => $this->student->national_id,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors('phone');
    }

    public function test_payment_for_tuition_does_not_require_reference_number()
    {
        $file = UploadedFile::fake()->create('receipt.png', 100, 'image/png');

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/payments', [
            'amount' => 500.00,
            'purpose' => 'الرسوم الدراسية',
            'receipt_image' => $file,
            'payment_category' => 'tuition_fee',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('payments', [
            'student_id' => $this->student->id,
            'amount' => 500.00,
        ]);
    }

    public function test_payment_for_grievance_requires_reference_number()
    {
        $file = UploadedFile::fake()->create('receipt.png', 100, 'image/png');

        // Without reference number
        $response = $this->actingAs($this->studentUser)->postJson('/api/student/payments', [
            'amount' => 10.00,
            'purpose' => 'تظلم درجة',
            'receipt_image' => $file,
            'payment_category' => 'grievance',
        ]);

        $response->assertStatus(422);
        $response->assertJsonFragment(['error' => 'الرقم المرجعي مطلوب لهذا النوع من المدفوعات.']);
    }

    public function test_payment_for_grievance_succeeds_with_valid_reference_number()
    {
        $file = UploadedFile::fake()->create('receipt.png', 100, 'image/png');

        // Create a mock Grievance (Appeal)
        $appeal = Appeal::create([
            'student_id' => $this->student->id,
            'semester_id' => $this->semester->id,
            'status' => AppealStatusEnum::PENDING,
        ]);

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/payments', [
            'amount' => 10.00,
            'purpose' => 'تظلم درجة',
            'receipt_image' => $file,
            'ref_number' => 'REF-' . $appeal->id,
            'payment_category' => 'grievance',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('payments', [
            'student_id' => $this->student->id,
            'appeal_id' => $appeal->id,
            'amount' => 10.00,
        ]);
    }
}
