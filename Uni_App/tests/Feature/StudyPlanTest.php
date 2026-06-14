<?php

namespace Tests\Feature;

use App\Models\Program;
use App\Models\Student;
use App\Models\StudyPlan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class StudyPlanTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'student']);
        \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'student_affairs']);
    }

    public function test_student_affairs_can_upload_and_replace_study_plan()
    {
        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff1']);
        $staff->assignRole('student_affairs');
        $program = Program::factory()->create();

        $file1 = UploadedFile::fake()->create('plan1.pdf', 100, 'application/pdf');

        $response = $this->actingAs($staff)->postJson('/api/staff/study-plans', [
            'program_id' => $program->id,
            'title'      => 'First Plan',
            'file'       => $file1,
        ]);

        $response->assertStatus(201);
        $plan = StudyPlan::where('program_id', $program->id)->first();
        Storage::disk('public')->assertExists($plan->file_path);

        $oldFilePath = $plan->file_path;

        // Replace the file
        $file2 = UploadedFile::fake()->create('plan2.pdf', 100, 'application/pdf');
        $response2 = $this->actingAs($staff)->postJson('/api/staff/study-plans', [
            'program_id' => $program->id,
            'title'      => 'Second Plan',
            'file'       => $file2,
        ]);

        $response2->assertStatus(201);
        Storage::disk('public')->assertMissing($oldFilePath);

        $plan->refresh();
        $this->assertEquals('Second Plan', $plan->title);
        Storage::disk('public')->assertExists($plan->file_path);
    }

    public function test_student_cannot_access_other_program_plan()
    {
        $program1 = Program::factory()->create();
        $program2 = Program::factory()->create();

        $studentUser = User::factory()->create(['role' => 'student', 'username' => 'student1']);
        $studentUser->assignRole('student');
        Student::factory()->create(['user_id' => $studentUser->id, 'program_id' => $program1->id]);

        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff2']);
        $staff->assignRole('student_affairs');

        StudyPlan::create([
            'program_id'  => $program2->id, // Another program's plan
            'title'       => 'Other Plan',
            'file_path'   => 'fake/path.pdf',
            'uploaded_by' => $staff->id,
        ]);

        $response = $this->actingAs($studentUser)->getJson('/api/student/study-plan');

        $response->assertStatus(404);
        $response->assertJson(['message' => 'Study plan not found for your program.']);
    }

    public function test_student_can_access_own_program_plan()
    {
        $program = Program::factory()->create();
        $studentUser = User::factory()->create(['role' => 'student', 'username' => 'student2']);
        $studentUser->assignRole('student');
        Student::factory()->create(['user_id' => $studentUser->id, 'program_id' => $program->id]);

        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff3']);
        $staff->assignRole('student_affairs');

        StudyPlan::create([
            'program_id'  => $program->id,
            'title'       => 'My Plan',
            'file_path'   => 'my/plan.pdf',
            'uploaded_by' => $staff->id,
        ]);

        $response = $this->actingAs($studentUser)->getJson('/api/student/study-plan');

        $response->assertStatus(200);
        $response->assertJsonPath('data.title', 'My Plan');
    }
}
