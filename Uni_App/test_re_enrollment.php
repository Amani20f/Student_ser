<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Models\RequestType;

$student = Student::find(2); // Student 2 is currently suspended

// 1. Submit Request via ServiceRequestController
$controller = app(\App\Http\Controllers\Api\ServiceRequestController::class);
$request = \Illuminate\Http\Request::create('/api/student/requests', 'POST', [
    'request_type_id' => 3, // re_enrollment
    'student_id' => 2,
    'prev_stops_count' => '1',
    'prev_semester' => 'الأول',
    'description' => 'E2E Test Re-enrollment'
]);
$request->setUserResolver(function () use ($student) {
    return $student->user;
});

// Mock file upload
$file = \Illuminate\Http\UploadedFile::fake()->create('stop_form.pdf', 100);
$request->files->set('suspension_form', $file);
$request->files->set('university_id', $file);

try {
    $response = $controller->store($request);
    echo "1. Request Submission Response:\n";
    echo json_encode($response->getData(), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    $data = $response->getData(true);
    if (!isset($data['data']['id'])) {
        die("Failed to create request");
    }
    $requestId = $data['data']['id'];

    // 2. Fetch from DB
    $reqModel = \App\Models\Request::with('reEnrollmentDetail')->find($requestId);
    echo "2. Database Record:\n";
    echo "Status: " . $reqModel->status->value . "\n";
    echo "Detail Exists: " . ($reqModel->reEnrollmentDetail ? 'Yes' : 'No') . "\n\n";

    // 3. Admin Approval Pipeline (Accountant -> Student Affairs -> Approve)
    $service = app(\App\Services\Request\ReEnrollmentService::class);
    $admin = \App\Models\User::role('admin')->first();
    
    // Accountant step
    $service->ratifyByAccountant($reqModel, ['university_fees' => 10, 'other_fees' => 0], $admin);
    echo "3. Accountant Ratified\n";
    
    // Student Affairs step
    $service->ratifyByStudentAffairs($reqModel, [
        'major' => 'IT', 'level' => 3, 'batch' => '2023', 'academic_year' => '2025/2026'
    ], $admin);
    echo "4. Student Affairs Ratified\n";
    
    // Final Approval
    $service->approveReEnrollment($reqModel, $admin);
    echo "5. Final Approval Granted\n\n";

    $student->refresh();
    echo "Final Student Status: " . $student->status->value . "\n";

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}
