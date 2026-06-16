<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// Force authenticate as Student 1 (Computer Science)
$user = App\Models\User::find(5); // Student 1 is User 5 (based on previous check)
auth()->login($user);

$controller = new App\Http\Controllers\Api\Student\AcademicRecordController();
$request = Illuminate\Http\Request::create('/api/student/academic-record/results', 'GET');
$response = $controller->results($request);

echo "RESPONSE JSON:\n";
echo json_encode(json_decode($response->getContent()), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
