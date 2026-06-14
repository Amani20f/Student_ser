<?php

namespace Tests\Feature;

use App\Models\StudentApplication;
use App\Models\User;
use App\Models\Program;
use App\Models\Department;
use App\Models\College;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class StudentApplicationManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Ensure we have roles
        Role::create(['name' => 'admin']);
        Role::create(['name' => 'student_affairs']);
        Role::create(['name' => 'student']);

        // Ensure we have a program
        $college = College::create(['name' => 'College of IT', 'code' => 'CIT']);
        $department = Department::create(['name' => 'CS', 'code' => 'CS_DEP', 'college_id' => $college->id]);
        $this->program = Program::create(['name' => 'BSc CS', 'code' => 'BSC_CS', 'department_id' => $department->id]);
    }

    private function createStudentApplication()
    {
        return StudentApplication::create([
            'application_number' => 'APP-' . time(),
            'full_name' => 'John Doe',
            'national_id_number' => '1234567890',
            'email_address' => 'john@example.com',
            'phone_number' => '1234567890',
            'gender' => 'male',
            'nationality' => 'Saudi',
            'date_of_birth' => '2000-01-01',
            'address' => 'Riyadh',
            'desired_program_id' => $this->program->id,
            'desired_academic_level' => 1,
            'application_status' => 'pending',
            'submitted_at' => now(),
        ]);
    }

    public function test_admin_can_view_applications()
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $admin->assignRole('admin');
        $this->createStudentApplication();

        $response = $this->actingAs($admin)->getJson('/api/admin/applications');

        $response->assertStatus(200);
        $response->assertJsonStructure(['success', 'data']);
        $this->assertNotEmpty($response->json('data'));
    }

    public function test_student_affairs_can_view_applications()
    {
        $studentAffairs = User::factory()->create(['role' => 'student_affairs']);
        $studentAffairs->assignRole('student_affairs');
        $this->createStudentApplication();

        $response = $this->actingAs($studentAffairs)->getJson('/api/admin/applications');

        $response->assertStatus(200);
        $response->assertJsonStructure(['success', 'data']);
        $this->assertNotEmpty($response->json('data'));
    }

    public function test_student_affairs_can_view_application_details()
    {
        $studentAffairs = User::factory()->create(['role' => 'student_affairs']);
        $studentAffairs->assignRole('student_affairs');
        $app = $this->createStudentApplication();

        $response = $this->actingAs($studentAffairs)->getJson("/api/admin/applications/{$app->id}");

        $response->assertStatus(200);
        $response->assertJsonPath('data.id', $app->id);
    }

    public function test_student_affairs_can_approve_application()
    {
        $studentAffairs = User::factory()->create(['role' => 'student_affairs']);
        $studentAffairs->assignRole('student_affairs');
        $app = $this->createStudentApplication();

        $response = $this->actingAs($studentAffairs)->postJson("/api/admin/applications/{$app->id}/approve");

        $response->assertStatus(201);
        $this->assertDatabaseHas('student_applications', [
            'id' => $app->id,
            'application_status' => 'completed',
        ]);
        
        // Also check if user was created
        $this->assertDatabaseHas('users', [
            'email' => $app->email_address,
            'role' => 'student',
        ]);
    }

    public function test_student_affairs_can_reject_application()
    {
        $studentAffairs = User::factory()->create(['role' => 'student_affairs']);
        $studentAffairs->assignRole('student_affairs');
        $app = $this->createStudentApplication();

        $response = $this->actingAs($studentAffairs)->postJson("/api/admin/applications/{$app->id}/reject", [
            'rejection_reason' => 'Missing documents',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('student_applications', [
            'id' => $app->id,
            'application_status' => 'rejected',
            'rejection_reason' => 'Missing documents',
        ]);
    }

    public function test_student_cannot_view_applications()
    {
        $student = User::factory()->create(['role' => 'student']);
        $student->assignRole('student');
        
        $response = $this->actingAs($student)->getJson('/api/admin/applications');
        
        $response->assertStatus(403);
    }
}
