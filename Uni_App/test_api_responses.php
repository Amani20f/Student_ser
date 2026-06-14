<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$user = \App\Models\User::whereHas('roles', function($q) { $q->where('name', 'student'); })->first();

echo "User ID: " . $user->id . "\n";
echo "Initial username: " . $user->username . "\n";

// 1. GET Profile
$request1 = Illuminate\Http\Request::create('/api/student/profile', 'GET');
$request1->setUserResolver(function () use ($user) { return $user; });
$response1 = $kernel->handle($request1);
echo "GET /api/student/profile Response:\n" . $response1->getContent() . "\n\n";

// 2. PUT Profile
$request2 = Illuminate\Http\Request::create('/api/student/profile', 'PUT', [
    'name' => 'John Doe Tested',
    'email' => 'johndoe@test.com',
    'username' => 'johndoe_updated',
    'phone' => '0512345678',
    'national_id' => '999888777'
]);
$request2->setUserResolver(function () use ($user) { return $user; });
$response2 = $kernel->handle($request2);
echo "PUT /api/student/profile Response:\n" . $response2->getContent() . "\n\n";

// 3. Verify Database Update
$user->refresh();
echo "Updated User Data from DB:\n";
echo "Name: " . $user->name . "\n";
echo "Email: " . $user->email . "\n";
echo "Username: " . $user->username . "\n";
echo "Phone: " . $user->student->phone . "\n";
echo "National ID: " . $user->student->national_id . "\n\n";

// 4. PUT Password (Wrong current password)
$request3 = Illuminate\Http\Request::create('/api/student/change-password', 'PUT', [
    'current_password' => 'wrongpassword',
    'new_password' => 'newvalidpass123',
    'new_password_confirmation' => 'newvalidpass123'
]);
$request3->setUserResolver(function () use ($user) { return $user; });
$response3 = $kernel->handle($request3);
echo "PUT /change-password (Wrong Pass) Response:\n" . $response3->getContent() . "\n\n";

// 5. PUT Password (Correct current password)
$request4 = Illuminate\Http\Request::create('/api/student/change-password', 'PUT', [
    'current_password' => 'password', // Assumed seeded password is 'password'
    'new_password' => 'newvalidpass123',
    'new_password_confirmation' => 'newvalidpass123'
]);
$request4->setUserResolver(function () use ($user) { return $user; });
$response4 = $kernel->handle($request4);
echo "PUT /change-password (Correct Pass) Response:\n" . $response4->getContent() . "\n\n";

// Revert password
$user->update(['password' => \Illuminate\Support\Facades\Hash::make('password')]);
