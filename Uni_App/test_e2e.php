<?php
require __DIR__."/vendor/autoload.php";
$app = require_once __DIR__."/bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$service = app(\App\Services\Academic\GradeImportService::class);

$csvPath = storage_path('app/temp/imports/test_grades.csv');
@mkdir(dirname($csvPath), 0755, true);

$csvContent = <<<CSV
Student ID / Number,Course Code,First Exam,Second Exam,Midterm Exam,Final Exam,Grade Estimate
S202600001,CS101,15,15,20,40,
INVALID-STU,CS101,10,10,10,10,
S202600001,INVALID-CRS,10,10,10,10,
S202600002,CS101,,,,,excellent
CSV;

file_put_contents($csvPath, $csvContent);

$mapping = [
    'student_number' => 'Student ID / Number',
    'course_code' => 'Course Code',
    'first' => 'First Exam',
    'second' => 'Second Exam',
    'midterm' => 'Midterm Exam',
    'final' => 'Final Exam',
    'grade_estimate' => 'Grade Estimate'
];

$semesterId = 1; // Assuming semester 1 exists.

echo "\n--- 3. Import Preview (Validate) ---\n";
$validateStats = $service->validateImport($csvPath, $mapping, $semesterId);
echo json_encode($validateStats, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

echo "\n--- 4. Import Processing (Store) ---\n";
$storeStats = $service->processImport($csvPath, $mapping, $semesterId);
echo json_encode($storeStats, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";

echo "\n--- 5. Database Verification ---\n";
$grades = \App\Models\Grade::with(['student', 'course'])->whereIn('student_id', [1, 2])->where('course_id', 1)->where('semester_id', $semesterId)->get();
foreach ($grades as $grade) {
    $est = $grade->grade_estimate instanceof \BackedEnum ? $grade->grade_estimate->value : $grade->grade_estimate;
    echo "Student: {$grade->student->student_number} | Course: {$grade->course->course_code} | Total: {$grade->total} | Estimate: {$est}\n";
}
