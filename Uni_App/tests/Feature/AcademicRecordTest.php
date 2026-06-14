<?php

namespace Tests\Feature;

use App\Enums\GradeStatusEnum;
use App\Models\Course;
use App\Models\Grade;
use App\Models\Program;
use App\Models\Semester;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AcademicRecordTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $student;
    protected $semester1;
    protected $semester2;
    protected $course1;
    protected $course2;

    protected function setUp(): void
    {
        parent::setUp();

        // Create user and student
        \Spatie\Permission\Models\Role::create(['name' => 'student']);
        $this->user = User::create([
            'name' => 'Test User',
            'username' => 'testuser' . rand(),
            'email' => 'test' . rand() . '@example.com',
            'password' => bcrypt('password'),
            'role' => 'student'
        ]);
        $this->user->assignRole('student');

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
        
        $this->student = Student::create([
            'user_id' => $this->user->id,
            'program_id' => $program->id,
            'student_number' => 'S123456',
            'phone' => '12345678',
            'status' => 'active',
            'cumulative_gpa' => 0.0,
            'completed_credit_hours' => 0,
        ]);

        // Create semesters
        $this->semester1 = Semester::create([
            'academic_year' => '2023-2024',
            'term' => 'first',
            'is_active' => false,
            'start_date' => '2023-09-01',
            'end_date' => '2023-12-30',
        ]);
        
        $this->semester2 = Semester::create([
            'academic_year' => '2023-2024',
            'term' => 'second',
            'is_active' => true,
            'start_date' => '2024-01-15',
            'end_date' => '2024-05-30',
        ]);

        // Create courses
        $this->course1 = Course::create([
            'program_id' => $program->id,
            'course_code' => 'CS101',
            'course_name' => 'Intro to CS',
            'credit_hours' => 3,
            'semester_level' => 1,
            'order_index' => 1,
        ]);

        $this->course2 = Course::create([
            'program_id' => $program->id,
            'course_code' => 'CS102',
            'course_name' => 'Data Structures',
            'credit_hours' => 4,
            'semester_level' => 2,
            'order_index' => 2,
        ]);

        // Create grades
        Grade::create([
            'student_id' => $this->student->id,
            'course_id' => $this->course1->id,
            'semester_id' => $this->semester1->id,
            'first' => 20,
            'second' => 20,
            'midterm' => 20,
            'final' => 30,
            'total' => 90,
            'gpa' => 4.0,
            'status' => GradeStatusEnum::PASSED,
        ]);

        Grade::create([
            'student_id' => $this->student->id,
            'course_id' => $this->course2->id,
            'semester_id' => $this->semester2->id,
            'first' => 15,
            'second' => 15,
            'midterm' => 15,
            'final' => 40,
            'total' => 85,
            'gpa' => 3.5,
            'status' => GradeStatusEnum::PASSED,
        ]);
        
        $this->student->recalculateGPAAndCredits();
    }

    public function test_can_get_results()
    {
        $response = $this->actingAs($this->user)->getJson('/api/student/results');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                'semester',
                'courses' => [
                    '*' => [
                        'course_code',
                        'course_name',
                        'first',
                        'second',
                        'midterm',
                        'final',
                        'total',
                        'status',
                    ]
                ]
            ]
        ]);

        $data = $response->json('data');
        $this->assertEquals('second 2023-2024', $data['semester']);
        $this->assertCount(1, $data['courses']);
        $this->assertEquals('CS102', $data['courses'][0]['course_code']);
        $this->assertEquals(85, $data['courses'][0]['total']);
    }

    public function test_cannot_get_results_without_required_survey()
    {
        // Create a required survey for the active semester
        $survey = \App\Models\Survey::create([
            'title' => 'End of Semester Evaluation',
            'google_form_url' => 'http://example.com/form',
            'semester_id' => $this->semester2->id,
            'is_active' => true,
            'is_required_for_grades' => true,
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/student/results');

        $response->assertStatus(403);
        $response->assertJson([
            'error' => 'questionnaire_required',
        ]);
        $response->assertJsonStructure([
            'error', 'message', 'survey' => ['id', 'title', 'url']
        ]);
    }

    public function test_can_get_results_with_completed_survey()
    {
        // Create a required survey for the active semester
        $survey = \App\Models\Survey::create([
            'title' => 'End of Semester Evaluation',
            'google_form_url' => 'http://example.com/form',
            'semester_id' => $this->semester2->id,
            'is_active' => true,
            'is_required_for_grades' => true,
        ]);

        // Complete the survey
        \App\Models\SurveyCompletion::create([
            'survey_id' => $survey->id,
            'student_id' => $this->student->id,
            'completed_at' => now(),
        ]);

        $response = $this->actingAs($this->user)->getJson('/api/student/results');

        $response->assertStatus(200);
        $this->assertEquals('second 2023-2024', $response->json('data.semester'));
    }

    public function test_can_get_transcript()
    {
        $response = $this->actingAs($this->user)->getJson('/api/student/transcript');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                'CGPA',
                'total_completed_credit_hours',
                'transcript' => [
                    '*' => [
                        'semester',
                        'earned_credit_hours',
                        'total_credit_hours',
                        'GPA',
                        'courses' => [
                            '*' => [
                                'course_code',
                                'course_name',
                                'total',
                                'status',
                            ]
                        ]
                    ]
                ]
            ]
        ]);

        $data = $response->json('data');
        
        // 3 credits * 4.0 + 4 credits * 3.5 = 12 + 14 = 26. 26 / 7 = 3.71
        $this->assertEquals(3.71, $data['CGPA']);
        $this->assertEquals(7, $data['total_completed_credit_hours']);
        
        $transcript = $data['transcript'];
        $this->assertCount(2, $transcript);
        
        $this->assertEquals('first 2023-2024', $transcript[0]['semester']);
        $this->assertEquals(3, $transcript[0]['earned_credit_hours']);
        $this->assertEquals(3, $transcript[0]['total_credit_hours']);
        $this->assertEquals(4.0, $transcript[0]['GPA']);
        
        $this->assertEquals('second 2023-2024', $transcript[1]['semester']);
        $this->assertEquals(4, $transcript[1]['earned_credit_hours']);
        $this->assertEquals(4, $transcript[1]['total_credit_hours']);
        $this->assertEquals(3.5, $transcript[1]['GPA']);
    }
}
