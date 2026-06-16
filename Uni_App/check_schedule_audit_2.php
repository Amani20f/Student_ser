<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$output = [];

// Get all programs to check for duplicates or name matches
$programs = \App\Models\Program::all();
$output['programs'] = $programs->map(function($p) { return ['id' => $p->id, 'name' => $p->name]; });

// Get all schedules
$schedules = \App\Models\StudySchedule::with('program')->get();
$output['all_schedules'] = $schedules->map(function($s) {
    return [
        'id' => $s->id,
        'program_id' => $s->program_id,
        'program_name' => $s->program->name ?? null,
        'level' => $s->level,
        'semester_id' => $s->semester_id,
        'file_path' => $s->file_path,
        'file_exists_physically' => file_exists(storage_path('app/public/'.$s->file_path)),
    ];
});

// Get all students
$students = \App\Models\Student::with('program', 'user')->get();
$output['all_students'] = $students->map(function($s) {
    return [
        'student_id' => $s->id,
        'user_id' => $s->user_id,
        'email' => $s->user->email ?? null,
        'program_id' => $s->program_id,
        'program_name' => $s->program->name ?? null,
        'current_level' => $s->current_level,
    ];
});

// Active Semester
$activeSemester = \App\Models\Semester::active()->first();
$output['active_semester'] = $activeSemester ? $activeSemester->toArray() : null;

echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
