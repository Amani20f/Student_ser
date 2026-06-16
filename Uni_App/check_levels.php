<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

$levels = Student::select('current_level')
    ->selectRaw('COUNT(*) as count')
    ->groupBy('current_level')
    ->orderBy('current_level')
    ->get();

echo "Counts of students per current_level:\n";
foreach($levels as $level) {
    echo "Level: " . $level->current_level . " | Count: " . $level->count . "\n";
}

echo "\nExamples:\n";
for ($i = 1; $i <= 10; $i++) {
    $student = Student::where('current_level', $i)->first();
    if ($student) {
        echo "Student ID: {$student->id} | Name: {$student->user->name} | Level: {$student->current_level}\n";
    }
}
