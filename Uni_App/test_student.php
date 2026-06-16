<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$student = App\Models\Student::find(8);

$programId = $student->program_id;
$collegeId = $student->program?->department?->college_id;
$currentLevel = $student->current_level;

echo "programId: " . var_export($programId, true) . "\n";
echo "collegeId: " . var_export($collegeId, true) . "\n";
echo "currentLevel: " . var_export($currentLevel, true) . "\n";

$requiredSurvey = \App\Models\Survey::where('is_active', true)
    ->where('is_required_for_grades', true)
    ->where(function($query) use ($programId, $collegeId, $currentLevel) {
        $query->where(function ($sub) use ($collegeId) {
            $sub->whereNull('target_college_id')->orWhere('target_college_id', $collegeId);
        })
        ->where(function ($sub) use ($programId) {
            $sub->whereNull('target_program_id')->orWhere('target_program_id', $programId);
        })
        ->where(function ($sub) use ($currentLevel) {
            $sub->whereNull('target_level')->orWhere('target_level', $currentLevel);
        });
    })
    ->first();

echo "Required Survey ID: " . ($requiredSurvey ? $requiredSurvey->id : "NONE") . "\n";
