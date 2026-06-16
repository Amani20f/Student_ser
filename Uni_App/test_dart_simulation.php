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
    'request_type_id' => '2',
    'suspension_reason' => 'I need a break',
    'start_semester_id' => '4',
    'duration_semesters' => '1'
]);
$file = \Illuminate\Http\UploadedFile::fake()->create('test_attachment.pdf', 100);
$request->files->set('attachment', $file);

// To capture validation response, we catch ValidationException
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

echo "=== 3. Validation Errors Array ===\n";
if (isset($data['errors'])) {
    print_r($data['errors']);
}
echo "\n";

echo "=== 4. Actual Payload sent by Flutter (simulated) ===\n";
print_r($request->all());
echo "\n";

echo "=== 5. Current StoreSuspensionRequest Rules ===\n";
$requestObj = new \App\Http\Requests\Request\StoreSuspensionRequest();
print_r($requestObj->rules());
