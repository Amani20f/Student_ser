<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/student/service-requests', 'POST', [
    'request_type_id' => 2,
    'suspension_reason' => 'Test reason more than 10 chars',
    'start_semester_id' => 1,
    'duration_semesters' => 1,
], [], [
    'attachment' => new \Illuminate\Http\UploadedFile(
        __DIR__.'/dummy.txt',
        'dummy.txt',
        'text/plain',
        null,
        true
    )
], []);

// Bypass auth by acting as student
$user = \App\Models\User::where('role', 'student')->first();
$app->make('auth')->login($user);

$response = $kernel->handle($request);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Content: " . $response->getContent() . "\n";
