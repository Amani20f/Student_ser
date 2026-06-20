<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Laravel\Sanctum\Sanctum;

// Bind request to container
$initialRequest = Illuminate\Http\Request::create('/', 'GET');
$app->instance('request', $initialRequest);

// Find a student
$studentUser = User::where('role', 'student')->first();
if (!$studentUser) {
    echo "No student found in database.\n";
    exit(1);
}

Sanctum::actingAs($studentUser, ['*']);
echo "Testing endpoints for student: " . $studentUser->email . " (ID: " . $studentUser->id . ")\n\n";

$endpoints = [
    'Requests (activeTypes)' => ['/api/student/request-types', 'GET'],
    'Previous Requests'      => ['/api/student/my-requests', 'GET'],
    'Courses List'           => ['/api/courses', 'GET'],
    'Announcements'          => ['/api/student/announcements', 'GET'],
    'Surveys'                => ['/api/student/optional-surveys', 'GET'],
    'Notifications'          => ['/api/student/notifications', 'GET'],
    'Grades'                 => ['/api/student/grades', 'GET'],
    'Results'                => ['/api/student/results', 'GET'],
    'Transcript'             => ['/api/student/transcript', 'GET'],
    'Current Courses'        => ['/api/student/current-courses', 'GET'],
    'Profile'                => ['/api/student/profile', 'GET'],
    'Payments'               => ['/api/student/payments', 'GET'],
    'Semesters'              => ['/api/semesters', 'GET'],
];

foreach ($endpoints as $name => $info) {
    $uri = $info[0];
    $method = $info[1];
    
    $request = Illuminate\Http\Request::create($uri, $method);
    $app->instance('request', $request);
    $response = app()->handle($request);
    
    $status = $response->getStatusCode();
    $content = json_decode($response->getContent(), true);
    
    $success = ($status >= 200 && $status < 300);
    $resultStr = $success ? "✓ PASS" : "✗ FAIL (Response: " . $response->getContent() . ")";
    
    echo sprintf("%-25s | %-30s | %-5s | %s\n", $name, $uri, $status, $resultStr);
}
