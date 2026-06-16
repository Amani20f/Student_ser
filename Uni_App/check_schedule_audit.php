<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$output = [];

// 1. Latest Study Schedule
$latestSchedule = \App\Models\StudySchedule::orderBy('id', 'desc')->first();
$output['latest_schedule'] = $latestSchedule ? [
    'id' => $latestSchedule->id,
    'program_id' => $latestSchedule->program_id,
    'level' => $latestSchedule->level,
    'semester_id' => $latestSchedule->semester_id,
    'file_path' => $latestSchedule->file_path,
] : null;

// 2. Test Student Data
$user = \App\Models\User::where('role', 'student')->first();
$testStudent = $user ? $user->student : \App\Models\Student::first();
$output['test_student'] = $testStudent ? [
    'student_id' => $testStudent->id,
    'user_id' => $testStudent->user_id,
    'program_id' => $testStudent->program_id,
    'current_level' => $testStudent->current_level,
] : null;

// 6. Active Semester
$activeSemester = \App\Models\Semester::active()->first();
$output['active_semester'] = $activeSemester ? [
    'id' => $activeSemester->id,
    'name' => $activeSemester->name,
    'year' => $activeSemester->year,
] : null;

// 7. Execute Query Manually
if ($testStudent && $activeSemester) {
    $matchedSchedule = \App\Models\StudySchedule::where('program_id', $testStudent->program_id)
        ->where('semester_id', $activeSemester->id)
        ->where('level', $testStudent->current_level)
        ->first();
    
    $output['matched_schedule'] = $matchedSchedule ? $matchedSchedule->toArray() : null;
    
    // 8. Why it failed?
    if (!$matchedSchedule) {
        $output['failure_reason'] = [];
        $checkProgram = \App\Models\StudySchedule::where('program_id', $testStudent->program_id)->exists();
        $checkLevel = \App\Models\StudySchedule::where('level', $testStudent->current_level)->exists();
        $checkSemester = \App\Models\StudySchedule::where('semester_id', $activeSemester->id)->exists();
        
        $output['failure_reason'] = [
            'has_schedule_for_this_program' => $checkProgram,
            'has_schedule_for_this_level' => $checkLevel,
            'has_schedule_for_this_semester' => $checkSemester,
        ];
    }
}

echo json_encode($output, JSON_PRETTY_PRINT);
