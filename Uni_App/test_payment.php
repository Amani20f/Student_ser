<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

$student = Student::find(2);
\Illuminate\Support\Facades\Auth::login($student->user);

$controller = app(\App\Http\Controllers\Api\Student\PaymentController::class);
$request = \Illuminate\Http\Request::create('/api/student/payments', 'POST', [
    'amount' => 50.00,
    'purpose' => 'E2E Test Payment',
    'ref_number' => 'REF-999',
]);

$file = \Illuminate\Http\UploadedFile::fake()->create('receipt.pdf', 100);
$request->files->set('receipt_image', $file);

try {
    $response = $controller->store($request);
    echo "1. Request Submission Response:\n";
    $data = $response->getData(true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    if (!isset($data['data']['id'])) {
        die("Failed to create payment");
    }
    
    // Simulate Staff Approval
    $paymentId = $data['data']['id'];
    $staffController = app(\App\Http\Controllers\Api\Staff\PaymentController::class);
    $admin = \App\Models\User::role('admin')->first();
    \Illuminate\Support\Facades\Auth::login($admin);
    
    $verifyResponse = $staffController->verify($paymentId);
    echo "2. Verification Response:\n";
    echo json_encode($verifyResponse->getData(true), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
