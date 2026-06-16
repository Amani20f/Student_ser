<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

// 1. Get Student
$student = Student::find(2); // ID 2 => Active Student
\Illuminate\Support\Facades\Auth::login($student->user);

// 2. Mock Request precisely matching the new Dart payload
$controller = app(\App\Http\Controllers\Api\ServiceRequestController::class);

$payload = [
    'request_type_id' => '2',
    'form_data' => [
        'suspension_reason' => 'Testing stop enrollment payload format',
        'start_semester_id' => '4',
        'duration_semesters' => '1'
    ]
];

$request = \Illuminate\Http\Request::create('/api/student/requests', 'POST', $payload);

// Attachments[] array format as sent by Dart
$file1 = \Illuminate\Http\UploadedFile::fake()->create('stop_enrollment_doc.pdf', 100);
$request->files->set('attachments', [$file1]); // equivalent to attachments[0]

try {
    $response = $controller->store($request);
    $status = $response->getStatusCode();
    $data = $response->getData(true);
} catch (\Illuminate\Validation\ValidationException $e) {
    $status = $e->status;
    $data = [
        'message' => $e->getMessage(),
        'errors' => $e->errors()
    ];
} catch (\Exception $e) {
    $status = 500;
    $data = ['error' => $e->getMessage()];
}

echo "=== 1. HTTP Status Code ===\n";
echo $status . "\n\n";

echo "=== 2. Full JSON Response Body ===\n";
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

if ($status == 200 || $status == 201) {
    echo "=== 3. Database Verification ===\n";
    $requestId = $data['data']['id'] ?? null;
    if ($requestId) {
        $dbRecord = \App\Models\Request::find($requestId);
        echo "Request ID {$dbRecord->id} found in database. Status: {$dbRecord->status->value}\n";
    }

    echo "\n=== 4. Admin View Verification ===\n";
    // Check if admin can see it
    $adminController = app(\App\Http\Controllers\Api\Admin\ServiceRequestController::class);
    $adminReq = \Illuminate\Http\Request::create('/api/admin/requests', 'GET');
    $adminRes = $adminController->index($adminReq);
    
    $found = false;
    foreach ($adminRes->getData(true)['data'] ?? [] as $reqItem) {
        if ($reqItem['id'] == $requestId) {
            $found = true;
            echo "Request ID {$requestId} is visible in the Admin Queue!\n";
        }
    }
    if (!$found) {
        echo "Request ID {$requestId} NOT FOUND in admin queue!\n";
    }
}
