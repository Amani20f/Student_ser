<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

$student = Student::find(2);

\Illuminate\Support\Facades\Auth::login($student->user);

// 1. Submit Request via AppealController
$controller = app(\App\Http\Controllers\Api\Student\AppealController::class);
$request = \Illuminate\Http\Request::create('/api/student/appeals', 'POST', [
    'academic_year' => '2025/2026',
    'term' => 'الفصل الثاني',
    'student_note' => 'E2E Test Grievance',
    'items' => [
        ['course_id' => 1] // Assuming course 1 exists
    ]
]);
$request->setUserResolver(function () use ($student) {
    return $student->user;
});

// Mock file upload
$file = \Illuminate\Http\UploadedFile::fake()->create('evidence.pdf', 100);
$request->files->set('attachments', [$file]);

try {
    $appealRequest = \App\Http\Requests\Api\Appeal\StoreAppealRequest::createFrom($request);
    $appealRequest->setContainer(app());
    // Bypass validation manually for test by setting a dummy validator
    $validator = \Illuminate\Support\Facades\Validator::make($request->all(), $appealRequest->rules());
    $appealRequest->setValidator($validator);

    $response = $controller->store($appealRequest);
    echo "1. Request Submission Response:\n";
    echo json_encode($response->getData(), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    $data = $response->getData(true);
    if (!isset($data['data']['id'])) {
        die("Failed to create request");
    }
    $appealId = $data['data']['id'];

    // 3. Admin Approval Pipeline (Accountant -> Grade Control -> Approve)
    $managementController = app(\App\Http\Controllers\Api\Staff\AppealManagementController::class);
    $admin = \App\Models\User::role('admin')->first();
    
    // Accountant step (verify payment)
    // Wait, AppealController@submitPayment creates the payment first. Let's do that!
    
} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}
