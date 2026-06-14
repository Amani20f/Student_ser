<?php

namespace Tests\Feature;

use App\Models\Program;
use App\Models\Request as ServiceRequest;
use App\Models\RequestType;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;
use Carbon\Carbon;

class AcademicSuspensionTest extends TestCase
{
    use RefreshDatabase;

    private $studentUser;
    private $student;
    private $requestType;
    private $semester1;
    private $semester2;
    private $semester3;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'student']);

        $this->requestType = RequestType::create([
            'name' => 'Academic Suspension',
            'slug' => 'suspension_of_enrollment',
            'is_active' => true,
        ]);

        $program = Program::factory()->create();

        $this->studentUser = User::factory()->create(['role' => 'student']);
        $this->studentUser->assignRole('student');

        $this->student = Student::factory()->create([
            'user_id' => $this->studentUser->id,
            'program_id' => $program->id,
            'current_level' => 2,
            'status' => 'active',
        ]);

        $this->semester1 = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => Carbon::now()->addDays(20)->toDateString(),
        ]);

        $this->semester2 = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'second',
            'is_active' => false,
            'start_date' => '2027-02-01',
            'end_date' => '2027-06-15',
            'exams_start_date' => '2027-06-01',
        ]);

        $this->semester3 = Semester::create([
            'academic_year' => '2027/2028',
            'term' => 'first',
            'is_active' => false,
            'start_date' => '2027-09-01',
            'end_date' => '2028-01-15',
            'exams_start_date' => '2028-01-01',
        ]);
    }

    public function test_first_year_student_cannot_submit()
    {
        $this->student->update(['current_level' => 1]);

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Personal issues',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 1,
        ]);

        $response->assertStatus(400);
        $response->assertJson(['message' => 'First year students are not allowed to submit academic suspension requests.']);
    }

    public function test_student_with_pending_suspension_cannot_submit()
    {
        ServiceRequest::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->requestType->id,
            'status' => 'pending',
            'description' => 'Existing suspension',
        ]);

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Another issue',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 1,
        ]);

        $response->assertStatus(400);
        $response->assertJson(['message' => 'You already have a pending suspension request.']);
    }

    public function test_student_cannot_submit_within_14_days_of_finals()
    {
        $this->semester1->update(['exams_start_date' => Carbon::now()->addDays(10)->toDateString()]);

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Close to exams',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 1,
        ]);

        $response->assertStatus(400);
        $response->assertJson(['message' => 'يجب تقديم الطلب قبل أسبوعين من الامتحانات.']);
    }

    public function test_student_can_submit_successfully_when_eligible()
    {
        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Health reasons that require a break.',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 1,
            'notes' => 'Medical docs attached',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('requests', [
            'student_id' => $this->student->id,
            'request_type_id' => $this->requestType->id,
            'status' => 'pending',
        ]);
    }

    public function test_expected_end_semester_is_calculated_correctly()
    {
        // 2 semesters duration starting from semester 1 means end is semester 3.
        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Long health break required.',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 2,
        ]);

        $response->assertStatus(201);
        $request = ServiceRequest::latest()->first();
        
        $this->assertEquals($this->semester3->id, $request->form_data['expected_end_semester_id']);
    }

    public function test_student_can_view_own_suspension_requests()
    {
        $req = ServiceRequest::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->requestType->id,
            'status' => 'pending',
            'description' => 'Test',
            'form_data' => [
                'suspension_reason' => 'A very valid reason',
                'start_semester_id' => $this->semester1->id,
                'duration_semesters' => 1,
                'expected_end_semester_id' => $this->semester2->id,
            ],
        ]);

        $response = $this->actingAs($this->studentUser)->getJson('/api/student/suspension-requests');

        $response->assertStatus(200);
        $response->assertJsonPath('data.0.suspension_reason', 'A very valid reason');
        $response->assertJsonPath('data.0.duration_semesters', 1);

        $responseSingle = $this->actingAs($this->studentUser)->getJson("/api/student/suspension-requests/{$req->id}");
        $responseSingle->assertStatus(200);
        $responseSingle->assertJsonPath('data.suspension_reason', 'A very valid reason');
    }

    public function test_student_cannot_view_another_students_suspension()
    {
        $otherUser = User::factory()->create(['role' => 'student']);
        $otherUser->assignRole('student');
        $otherStudent = Student::factory()->create(['user_id' => $otherUser->id]);

        $req = ServiceRequest::create([
            'student_id' => $otherStudent->id,
            'request_type_id' => $this->requestType->id,
            'status' => 'pending',
            'description' => 'Test description',
        ]);

        $response = $this->actingAs($this->studentUser)->getJson("/api/student/suspension-requests/{$req->id}");

        $response->assertStatus(404);
    }

    public function test_suspension_attachments_upload_correctly()
    {
        $file = UploadedFile::fake()->create('document.pdf', 100, 'application/pdf');

        $response = $this->actingAs($this->studentUser)->postJson('/api/student/suspension-request', [
            'suspension_reason' => 'Health reasons',
            'start_semester_id' => $this->semester1->id,
            'duration_semesters' => 1,
            'attachment' => $file,
        ]);

        $response->assertStatus(201);
        $request = ServiceRequest::latest()->first();
        
        $this->assertNotNull($request->attachment);
        $this->assertArrayHasKey('attachment', $request->attachment);
        Storage::disk('public')->assertExists($request->attachment['attachment']);
    }
}
