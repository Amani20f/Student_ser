<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$studentUser = User::whereHas('roles', function($q) { $q->where('name', 'student'); })->first();

if (!$studentUser) {
    echo "No student user found.\n";
    exit;
}

echo "Testing with student: " . $studentUser->email . "\n";
echo "Initial name: " . $studentUser->name . "\n";
echo "Initial national_id: " . $studentUser->student->national_id . "\n";

// Login to get token
$response = $app->handle(Illuminate\Http\Request::create('/api/login', 'POST', [
    'login' => $studentUser->email,
    'password' => 'password'
]));
$content = json_decode($response->getContent(), true);
$token = $content['token'] ?? null;

if (!$token) {
    echo "Login failed.\n";
    exit;
}

echo "Login successful. Token obtained.\n\n";

// 1. Get Profile
echo "1. GET /api/student/profile\n";
$request = Illuminate\Http\Request::create('/api/student/profile', 'GET');
$request->headers->set('Authorization', 'Bearer ' . $token);
$request->headers->set('Accept', 'application/json');
$response = $app->handle($request);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Response: " . substr($response->getContent(), 0, 200) . "...\n\n";

// 2. Update Profile
echo "2. PUT /api/student/profile\n";
$updateRequest = Illuminate\Http\Request::create('/api/student/profile', 'PUT', [
    'name' => $studentUser->name . ' Updated',
    'email' => $studentUser->email,
    'phone' => '1234567890',
    'national_id' => 'NAT-' . rand(1000, 9999),
]);
$updateRequest->headers->set('Authorization', 'Bearer ' . $token);
$updateRequest->headers->set('Accept', 'application/json');
$response = $app->handle($updateRequest);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Response: " . substr($response->getContent(), 0, 200) . "...\n\n";

// Revert name back
$studentUser->update(['name' => str_replace(' Updated', '', $studentUser->name)]);

// 3. Change Password
echo "3. PUT /api/student/change-password\n";
$pwdRequest = Illuminate\Http\Request::create('/api/student/change-password', 'PUT', [
    'current_password' => 'password',
    'new_password' => 'newpassword123',
    'new_password_confirmation' => 'newpassword123',
]);
$pwdRequest->headers->set('Authorization', 'Bearer ' . $token);
$pwdRequest->headers->set('Accept', 'application/json');
$response = $app->handle($pwdRequest);
echo "Status: " . $response->getStatusCode() . "\n";
echo "Response: " . $response->getContent() . "\n\n";

// Revert password back
$studentUser->update(['password' => Hash::make('password')]);
echo "Password reverted.\n";
