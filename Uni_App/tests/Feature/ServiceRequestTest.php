<?php

namespace Tests\Feature;

use App\Enums\RequestStatusEnum;
use App\Models\Request;
use App\Models\RequestType;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ServiceRequestTest extends TestCase
{
    use RefreshDatabase;

    protected Student $student;
    protected RequestType $absenceExcuseType;
    protected User $staffUser;

    protected function setUp(): void
    {
        parent::setUp();

        // Seed roles and permissions
        $this->seed(RoleAndPermissionSeeder::class);

        // Create necessary test data
        $this->student = Student::factory()->create();
        $this->student->user->assignRole('student');
        
        $this->absenceExcuseType = RequestType::create([
            'name' => 'Absence Excuse',
            'slug' => 'absence_excuse',
            'description' => 'Submit excuse for course absences',
            'is_active' => true,
        ]);

        $this->staffUser = User::factory()->create();
        $this->staffUser->assignRole('student_affairs');
    }

    /** @test */
    public function it_can_create_an_absence_excuse_request_with_valid_data()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'request_type',
                    'status',
                    'form_data',
                    'submitted_at',
                ],
            ])
            ->assertJson([
                'success' => true,
                'message' => 'تم إرسال الطلب بنجاح',
                'data' => [
                    'status' => 'pending',
                ],
            ]);

        // Assert data exists in database
        $this->assertDatabaseHas('requests', [
            'student_id' => $this->student->id,
            'request_type_id' => $this->absenceExcuseType->id,
            'status' => 'pending',
        ]);

        // Assert form_data is stored as valid JSON/Array
        $request = Request::latest()->first();
        $this->assertIsArray($request->form_data);
        $this->assertEquals($formData['specialization'], $request->form_data['specialization']);
        $this->assertEquals($formData['level'], $request->form_data['level']);
        $this->assertEquals($formData['college'], $request->form_data['college']);
        $this->assertEquals($formData['semester'], $request->form_data['semester']);
        $this->assertEquals($formData['academic_year'], $request->form_data['academic_year']);
        $this->assertEquals($formData['absence_reason'], $request->form_data['absence_reason']);
        $this->assertCount(2, $request->form_data['courses']);
    }

    /** @test */
    public function it_validates_required_fields_for_absence_excuse()
    {
        Sanctum::actingAs($this->student->user);

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => [], // Empty form data
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors([
                'form_data.specialization',
                'form_data.level',
                'form_data.college',
                'form_data.semester',
                'form_data.academic_year',
                'form_data.absence_reason',
                'form_data.courses',
            ]);
    }

    /** @test */
    public function it_validates_absence_reason_minimum_length()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();
        $formData['absence_reason'] = 'Short'; // Less than 10 characters

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['form_data.absence_reason']);
    }

    /** @test */
    public function it_validates_academic_level_range()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();
        $formData['level'] = 10; // Invalid level (must be 1-8)

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['form_data.level']);
    }

    /** @test */
    public function it_validates_absence_date_not_in_future()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();
        $formData['courses'][0]['absence_date'] = now()->addDays(10)->format('Y-m-d');

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['form_data.courses.0.absence_date']);
    }

    /** @test */
    public function it_validates_academic_year_format()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();
        $formData['academic_year'] = '2025-2026'; // Wrong format (should be 2025/2026)

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['form_data.academic_year']);
    }

    /** @test */
    public function it_requires_at_least_one_course()
    {
        Sanctum::actingAs($this->student->user);

        $formData = $this->getValidAbsenceExcuseData();
        $formData['courses'] = []; // Empty courses array

        $response = $this->postJson('/api/student/service-requests', [
            'student_id' => $this->student->id,
            'type_id' => $this->absenceExcuseType->id,
            'form_data' => $formData,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['form_data.courses']);
    }

    /** @test */
    public function admin_can_accept_a_request()
    {
        Sanctum::actingAs($this->staffUser);

        $request = Request::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->absenceExcuseType->id,
            'description' => 'Test request',
            'status' => RequestStatusEnum::PENDING,
            'form_data' => $this->getValidAbsenceExcuseData(),
        ]);

        $response = $this->putJson("/api/staff/service-requests/{$request->id}/status", [
            'status' => 'approved',
            'admin_notes' => 'Medical documentation verified and approved.',
            'should_notify' => true,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'تم تحديث حالة الطلب',
                'data' => [
                    'status' => 'approved',
                    'admin_notes' => 'Medical documentation verified and approved.',
                ],
            ]);

        // Assert database was updated
        $this->assertDatabaseHas('requests', [
            'id' => $request->id,
            'status' => 'approved',
            'admin_notes' => 'Medical documentation verified and approved.',
        ]);
    }

    /** @test */
    public function admin_can_reject_a_request()
    {
        Sanctum::actingAs($this->staffUser);

        $request = Request::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->absenceExcuseType->id,
            'description' => 'Test request',
            'status' => RequestStatusEnum::PENDING,
            'form_data' => $this->getValidAbsenceExcuseData(),
        ]);

        $response = $this->putJson("/api/staff/service-requests/{$request->id}/status", [
            'status' => 'rejected',
            'admin_notes' => 'Insufficient medical documentation provided.',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'rejected',
                ],
            ]);

        // Assert database was updated
        $this->assertDatabaseHas('requests', [
            'id' => $request->id,
            'status' => 'rejected',
            'admin_notes' => 'Insufficient medical documentation provided.',
        ]);
    }

    /** @test */
    public function rejection_requires_admin_notes()
    {
        Sanctum::actingAs($this->staffUser);

        $request = Request::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->absenceExcuseType->id,
            'description' => 'Test request',
            'status' => RequestStatusEnum::PENDING,
            'form_data' => $this->getValidAbsenceExcuseData(),
        ]);

        $response = $this->putJson("/api/staff/service-requests/{$request->id}/status", [
            'status' => 'rejected',
            // Missing admin_notes
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['admin_notes']);
    }

    /** @test */
    public function it_can_retrieve_a_specific_request()
    {
        Sanctum::actingAs($this->student->user);

        $request = Request::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->absenceExcuseType->id,
            'description' => 'Test request',
            'status' => RequestStatusEnum::PENDING,
            'form_data' => $this->getValidAbsenceExcuseData(),
        ]);

        $response = $this->getJson("/api/student/service-requests/{$request->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'request_type',
                    'status',
                    'form_data',
                    'submitted_at',
                ],
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $request->id,
                    'status' => 'pending',
                ],
            ]);
    }

    /**
     * Get valid absence excuse form data for testing.
     */
    protected function getValidAbsenceExcuseData(): array
    {
        return [
            'specialization' => 'Computer Science',
            'level' => 3,
            'college' => 'College of Engineering',
            'semester' => 'first',
            'academic_year' => '2025/2026',
            'absence_reason' => 'Medical emergency requiring hospitalization for surgery and recovery period.',
            'courses' => [
                [
                    'course_name' => 'Software Engineering',
                    'absence_date' => '2026-02-01',
                    'day' => 'Saturday',
                ],
                [
                    'course_name' => 'Database Systems',
                    'absence_date' => '2026-02-03',
                    'day' => 'Monday',
                ],
            ],
        ];
    }
}
