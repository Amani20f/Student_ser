<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

function getSurveysForStudent($collegeId, $programId, $currentLevel) {
    return App\Models\Survey::where('is_active', true)
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
        })->get()->pluck('id')->toArray();
}

echo "Computer Science (Coll 1, Prog 1, Lvl 2): " . json_encode(getSurveysForStudent(1, 1, 2)) . "\n";
echo "Electrical Engineering (Coll 1, Prog 2, Lvl 2): " . json_encode(getSurveysForStudent(1, 2, 2)) . "\n";
echo "Business (Coll 2, Prog 3, Lvl 2): " . json_encode(getSurveysForStudent(2, 3, 2)) . "\n";
