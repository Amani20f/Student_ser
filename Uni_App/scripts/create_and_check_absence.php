<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Models\RequestType;
use App\Models\Request;
use App\Enums\RequestStatusEnum;
use App\Models\AbsenceExcuse;
use App\Models\Course;

// Find a student
$student = Student::first();
if (!$student) {
    echo "No student found.\n";
    exit(1);
}
// Get request type for absence_excuse
$requestType = RequestType::where('slug', 'absence_excuse')->first();
if (!$requestType) {
    echo "Request type 'absence_excuse' not found.\n";
    exit(1);
}
// Prepare form data
$formData = [
    'academic_year' => '2023/2024',
    'semester' => 'first',
    'absence_reason' => 'Testing absence excuse',
    'courses' => [
        [
            'course_id' => 1,
            'absence_date' => '2023-10-01',
            'day' => 'Saturday',
        ],
    ],
];
// Create request
$request = Request::create([
    'student_id' => $student->id,
    'request_type_id' => $requestType->id,
    'description' => 'Test absence excuse via script',
    'status' => RequestStatusEnum::PENDING,
    'form_data' => $formData,
    'attachment' => null,
]);
// Create related AbsenceExcuse
$absenceExcuse = $request->absenceExcuse()->create([
    'academic_year' => $formData['academic_year'],
    'semester' => $formData['semester'],
    'reason' => $formData['absence_reason'],
]);
// Add items
foreach ($formData['courses'] as $c) {
    $course = Course::find($c['course_id']);
    $courseName = $course ? $course->course_name : '';
    $absenceExcuse->items()->create([
        'course_id' => $c['course_id'],
        'course_name' => $courseName,
        'absence_date' => $c['absence_date'],
        'day' => $c['day'],
    ]);
}
// Verify
$item = $absenceExcuse->items()->first();
if ($item) {
    echo "Created AbsenceExcuseItem with day: " . ($item->day ?? 'null') . "\n";
} else {
    echo "No items created.\n";
}
?>
