<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$oldActive = \App\Models\Semester::where('is_active', true)->first();
if ($oldActive) {
    $oldActive->is_active = false;
    $oldActive->save();
}

$newSemester = \App\Models\Semester::create([
    'academic_year' => '2025/2026',
    'term' => 'second',
    'start_date' => '2026-02-01',
    'end_date' => '2026-07-31',
    'exams_start_date' => '2026-07-15',
    'is_active' => true,
]);
echo "Created new semester ID: " . $newSemester->id . "\n";
