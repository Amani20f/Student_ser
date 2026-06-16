<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$controller = app(\App\Http\Controllers\Api\StudentApplicationController::class);
$request = \Illuminate\Http\Request::create('/api/apply', 'POST', [
    'full_name' => 'E2E Test Student',
    'national_id_number' => '1234567890',
    'date_of_birth' => '2000-01-01',
    'gender' => 'male',
    'nationality' => 'سعودي',
    'phone_number' => '0500000000',
    'email_address' => 'test@test.com',
    'address' => 'Test Address',
    'desired_program_id' => 1,
    'desired_academic_level' => '1',
]);

$file = \Illuminate\Http\UploadedFile::fake()->create('doc.pdf', 100);
$imageFile = \Illuminate\Http\UploadedFile::fake()->create('photo.jpg', 100);
$request->files->set('identity_document', $file);
$request->files->set('qualification_document', $file);
$request->files->set('personal_photo', $imageFile);

try {
    $response = $controller->store($request);
    echo "1. Request Submission Response:\n";
    $data = $response->getData(true);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
