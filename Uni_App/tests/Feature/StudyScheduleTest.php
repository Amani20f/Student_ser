<?php

namespace Tests\Feature;

use App\Models\Program;
use App\Models\Semester;
use App\Models\Student;
use App\Models\StudySchedule;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class StudyScheduleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'student']);
        \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'student_affairs']);
    }

    public function test_student_affairs_can_upload_and_replace_study_schedule()
    {
        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff1']);
        $staff->assignRole('student_affairs');
        $program = Program::factory()->create();
        $semester = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => '2027-01-01',
        ]);

        $file1 = UploadedFile::fake()->create('schedule1.pdf', 100, 'application/pdf');

        $response = $this->actingAs($staff)->postJson('/api/staff/study-schedules', [
            'program_id'  => $program->id,
            'semester_id' => $semester->id,
            'level'       => 1,
            'title'       => 'First Schedule',
            'file'        => $file1,
        ]);

        $response->assertStatus(201);
        $schedule = StudySchedule::where('program_id', $program->id)->first();
        Storage::disk('public')->assertExists($schedule->file_path);

        $oldFilePath = $schedule->file_path;

        // Replace the file
        $file2 = UploadedFile::fake()->create('schedule2.pdf', 100, 'application/pdf');
        $response2 = $this->actingAs($staff)->postJson('/api/staff/study-schedules', [
            'program_id'  => $program->id,
            'semester_id' => $semester->id,
            'level'       => 1, // Same combination
            'title'       => 'Second Schedule',
            'file'        => $file2,
        ]);

        $response2->assertStatus(201);
        Storage::disk('public')->assertMissing($oldFilePath);

        $schedule->refresh();
        $this->assertEquals('Second Schedule', $schedule->title);
        Storage::disk('public')->assertExists($schedule->file_path);
    }

    public function test_student_cannot_access_other_program_schedule()
    {
        $program1 = Program::factory()->create();
        $program2 = Program::factory()->create();
        $semester = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => '2027-01-01',
        ]);

        $studentUser = User::factory()->create(['role' => 'student', 'username' => 'student1']);
        $studentUser->assignRole('student');
        Student::factory()->create([
            'user_id'       => $studentUser->id,
            'program_id'    => $program1->id,
            'current_level' => 1
        ]);

        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff2']);
        $staff->assignRole('student_affairs');

        StudySchedule::create([
            'program_id'  => $program2->id,
            'semester_id' => $semester->id,
            'level'       => 1,
            'title'       => 'Other Schedule',
            'file_path'   => 'fake/path.pdf',
            'uploaded_by' => $staff->id,
        ]);

        $response = $this->actingAs($studentUser)->getJson('/api/student/study-schedule');

        $response->assertStatus(404);
        $response->assertJson(['message' => 'Study schedule not found for your program, current level, and active semester.']);
    }

    public function test_student_can_access_own_program_schedule()
    {
        $program = Program::factory()->create();
        $semester = Semester::create([
            'academic_year' => '2026/2027',
            'term' => 'first',
            'is_active' => true,
            'start_date' => '2026-09-01',
            'end_date' => '2027-01-15',
            'exams_start_date' => '2027-01-01',
        ]);

        $studentUser = User::factory()->create(['role' => 'student', 'username' => 'student2']);
        $studentUser->assignRole('student');
        Student::factory()->create([
            'user_id'       => $studentUser->id,
            'program_id'    => $program->id,
            'current_level' => 3
        ]);

        $staff = User::factory()->create(['role' => 'student_affairs', 'username' => 'staff3']);
        $staff->assignRole('student_affairs');

        StudySchedule::create([
            'program_id'  => $program->id,
            'semester_id' => $semester->id,
            'level'       => 3,
            'title'       => 'My Schedule',
            'file_path'   => 'my/schedule.pdf',
            'uploaded_by' => $staff->id,
        ]);

        $response = $this->actingAs($studentUser)->getJson('/api/student/study-schedule');

        $response->assertStatus(200);
        $response->assertJsonPath('data.title', 'My Schedule');
    }
}
