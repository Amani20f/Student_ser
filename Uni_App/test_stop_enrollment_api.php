<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;

$student = Student::find(2); // Student user id 3
\Illuminate\Support\Facades\Auth::login($student->user);

$controller = app(\App\Http\Controllers\Api\ServiceRequestController::class);
$request = \Illuminate\Http\Request::create('/api/student/requests', 'POST', [
    'request_type_id' => 2,
    'form_data' => [
        'suspension_reason' => 'I need a break',
        'start_semester_id' => 4,
        'duration_semesters' => '1'
    ]
]);

$file = \Illuminate\Http\UploadedFile::fake()->create('suspension_doc.pdf', 100);
$request->files->set('attachments', [$file]);

try {
    $response = $controller->store($request);
    echo "Response:\n";
    echo json_encode($response->getData(true), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}
