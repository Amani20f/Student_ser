<?php

namespace Tests\Feature;

use App\Enums\RequestStatusEnum;
use App\Models\Program;
use App\Models\Request;
use App\Models\RequestType;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class StudentRequestTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $student;
    protected $otherStudent;
    protected $staffUser;
    protected $requestType;

    protected function setUp(): void
    {
        parent::setUp();

        Role::create(['name' => 'student']);
        Role::create(['name' => 'student_affairs']);

        $college = \App\Models\College::create([
            'name' => 'Test College',
            'code' => 'TC',
        ]);
        
        $department = \App\Models\Department::create([
            'college_id' => $college->id,
            'name' => 'Test Department',
            'code' => 'TD',
        ]);

        $program = Program::create([
            'name' => 'Test Program',
            'code' => 'TP01',
            'degree_type' => 'bachelor',
            'total_credit_hours' => 120,
            'department_id' => $department->id,
        ]);

        // Student 1 (Authenticated)
        $this->user = User::create([
            'name' => 'Test Student',
            'username' => 'student1',
            'email' => 'student1@example.com',
            'password' => bcrypt('password'),
            'role' => 'student'
        ]);
        $this->user->assignRole('student');

        $this->student = Student::create([
            'user_id' => $this->user->id,
            'program_id' => $program->id,
            'student_number' => 'S001',
            'phone' => '12345678',
            'status' => 'active',
            'cumulative_gpa' => 0.0,
            'completed_credit_hours' => 0,
        ]);

        // Student 2 (Other)
        $otherUser = User::create([
            'name' => 'Other Student',
            'username' => 'student2',
            'email' => 'student2@example.com',
            'password' => bcrypt('password'),
            'role' => 'student'
        ]);
        $otherUser->assignRole('student');

        $this->otherStudent = Student::create([
            'user_id' => $otherUser->id,
            'program_id' => $program->id,
            'student_number' => 'S002',
            'phone' => '87654321',
            'status' => 'active',
            'cumulative_gpa' => 0.0,
            'completed_credit_hours' => 0,
        ]);

        // Staff
        $this->staffUser = User::create([
            'name' => 'Staff Member',
            'username' => 'staff1',
            'email' => 'staff1@example.com',
            'password' => bcrypt('password'),
            'role' => 'student_affairs'
        ]);
        $this->staffUser->assignRole('student_affairs');

        // Request Type
        $this->requestType = RequestType::create([
            'name' => 'Transcript Request',
            'slug' => 'transcript_request',
            'description' => 'Request official transcript',
            'is_active' => true,
        ]);
    }

    public function test_student_can_view_paginated_list_of_own_requests()
    {
        // Create 15 requests for this student
        for ($i = 0; $i < 15; $i++) {
            Request::create([
                'student_id' => $this->student->id,
                'request_type_id' => $this->requestType->id,
                'description' => "Request $i",
                'status' => RequestStatusEnum::PENDING,
            ]);
        }

        // Create 1 request for other student
        Request::create([
            'student_id' => $this->otherStudent->id,
            'request_type_id' => $this->requestType->id,
            'description' => "Other Request",
            'status' => RequestStatusEnum::PENDING,
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/student/requests');

        $response->assertStatus(200);
        
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'request_type',
                    'status',
                    'created_at',
                    'updated_at'
                ]
            ],
            'meta' => [
                'current_page',
                'last_page',
                'per_page',
                'total'
            ]
        ]);

        $data = $response->json('data');
        $meta = $response->json('meta');

        $this->assertCount(10, $data); // First page of 10
        $this->assertEquals(15, $meta['total']); // Total 15
        $this->assertEquals(2, $meta['last_page']);
        
        // Assert we don't see the other student's request
        $this->assertStringNotContainsString('Other Request', json_encode($data));
    }

    public function test_student_can_view_request_details_with_processor_info()
    {
        $request = Request::create([
            'student_id' => $this->student->id,
            'request_type_id' => $this->requestType->id,
            'description' => "My detail request",
            'status' => RequestStatusEnum::APPROVED,
            'processed_by' => $this->staffUser->id,
            'admin_notes' => "Looks good",
        ]);

        // Manually update updated_at so processed_at differs from created_at
        $request->updated_at = now()->addDays(1);
        $request->save();

        $response = $this->actingAs($this->user)->getJson("/api/student/requests/{$request->id}");

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                'id',
                'request_type',
                'description',
                'attachment',
                'status',
                'created_at',
                'updated_at',
                'processed_by' => [
                    'name',
                    'role'
                ],
                'processed_at',
                'response'
            ]
        ]);

        $data = $response->json('data');
        $this->assertEquals('My detail request', $data['description']);
        $this->assertEquals('approved', $data['status']);
        $this->assertEquals('Looks good', $data['response']);
        $this->assertEquals('Staff Member', $data['processed_by']['name']);
        $this->assertEquals('student_affairs', $data['processed_by']['role']);
        $this->assertNotNull($data['processed_at']);
    }

    public function test_student_cannot_view_another_students_request()
    {
        $request = Request::create([
            'student_id' => $this->otherStudent->id,
            'request_type_id' => $this->requestType->id,
            'description' => "Other detail request",
            'status' => RequestStatusEnum::PENDING,
        ]);

        $response = $this->actingAs($this->user)->getJson("/api/student/requests/{$request->id}");

        $response->assertStatus(404);
    }
}
