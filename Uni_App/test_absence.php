<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

$student = Student::find(2);

\Illuminate\Support\Facades\Auth::login($student->user);

$controller = app(\App\Http\Controllers\Api\ServiceRequestController::class);
$request = \Illuminate\Http\Request::create('/api/student/requests', 'POST', [
    'request_type_id' => 1, // absence_excuse
    'student_id' => 2,
    'description' => 'E2E Test Absence Excuse',
    'form_data' => [
        'specialization' => 'IT',
        'level' => 3,
        'college' => 'Engineering',
        'academic_year' => '2025/2026',
        'semester' => 'first',
        'absence_reason' => 'I am very sick today',
        'courses' => [
            ['course_id' => 1, 'course_name' => 'Math', 'day' => 'Sunday', 'absence_date' => date('Y-m-d')]
        ]
    ]
]);

$file = \Illuminate\Http\UploadedFile::fake()->create('medical.pdf', 100);
$request->files->set('attachments', [$file]);

try {
    $response = $controller->store($request);
    echo "1. Request Submission Response:\n";
    $data = $response->getData(true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    $requestId = $data['data']['id'];
    $reqModel = \App\Models\Request::with('absenceExcuse')->find($requestId);
    echo "2. Database Record Absence Excuse Detail:\n";
    echo json_encode($reqModel->absenceExcuse, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
