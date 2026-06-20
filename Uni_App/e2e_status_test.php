<?php
// E2E Test: Test student status display after suspension approval
require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Models\User;
use App\Enums\StudentStatusEnum;

$baseUrl = 'http://localhost:8000/api';

echo "=== E2E TEST: STUDENT STATUS ===\n\n";

// Find a suspended student
$suspendedStudent = Student::where('status', StudentStatusEnum::SUSPENDED)->with('user')->first();
if (!$suspendedStudent) {
    echo "ERROR: No suspended student found\n";
    exit(1);
}

echo "Target Student: {$suspendedStudent->user->name}\n";
echo "Student ID: {$suspendedStudent->id}\n";
echo "DB Status (BEFORE): " . $suspendedStudent->status->value . "\n\n";

// Login as that student to get token
$loginData = json_encode([
    'email' => $suspendedStudent->user->email,
    'password' => 'password123' // Try default password
]);

$ch = curl_init("{$baseUrl}/login");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $loginData);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Accept: application/json']);
$loginResponse = curl_exec($ch);
$loginHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Login HTTP Code: {$loginHttpCode}\n";
$loginData = json_decode($loginResponse, true);

if ($loginHttpCode !== 200 || !isset($loginData['token'])) {
    echo "Login failed. Response: {$loginResponse}\n";
    echo "\nTrying to find real password...\n";
    
    // Try to get password from seeder or use another approach
    echo "\n=== DIRECT API PROFILE CHECK ===\n";
    echo "Simulating profile fetch for the suspended student...\n\n";
    
    // Simulate what UserResource returns for this student
    $student = $suspendedStudent;
    $user = $student->user;
    $user->load('student.program.department.college');
    
    $resource = new \App\Http\Resources\UserResource($user);
    $arr = $resource->toArray(new \Illuminate\Http\Request());
    
    echo "UserResource output:\n";
    echo json_encode($arr, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
    echo "student.status value from API: " . ($arr['student']['status'] ?? 'NOT FOUND') . "\n";
    exit(0);
}

$token = $loginData['token'];
echo "Login successful! Token obtained.\n\n";

// Now fetch profile
$ch = curl_init("{$baseUrl}/student/profile");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Accept: application/json'
]);
$profileResponse = curl_exec($ch);
$profileHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Profile API HTTP Code: {$profileHttpCode}\n";
$profileData = json_decode($profileResponse, true);
echo "student.status from API: " . ($profileData['data']['student']['status'] ?? 'NOT FOUND') . "\n\n";

echo "=== RESULT ===\n";
echo "DB Status: " . $suspendedStudent->status->value . "\n";
echo "API Status: " . ($profileData['data']['student']['status'] ?? 'NOT FOUND') . "\n";
echo "MATCH: " . ($suspendedStudent->status->value === ($profileData['data']['student']['status'] ?? '') ? "YES ✓" : "NO ✗") . "\n";

echo "\n=== NOTIFICATIONS TEST ===\n";
$ch = curl_init("{$baseUrl}/student/notifications");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Accept: application/json'
]);
$notifResponse = curl_exec($ch);
$notifHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$notifData = json_decode($notifResponse, true);
$notifCount = count($notifData['data'] ?? []);
echo "Notifications count BEFORE clear: {$notifCount}\n";

if ($notifCount > 0) {
    // Test clear all
    $ch = curl_init("{$baseUrl}/student/notifications");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Accept: application/json'
    ]);
    $clearResponse = curl_exec($ch);
    $clearHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "Clear All HTTP Code: {$clearHttpCode}\n";
    echo "Clear Response: {$clearResponse}\n";
    
    // Verify clear
    $ch = curl_init("{$baseUrl}/student/notifications");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Accept: application/json'
    ]);
    $notifAfterResponse = curl_exec($ch);
    curl_close($ch);
    
    $notifAfterData = json_decode($notifAfterResponse, true);
    $notifAfterCount = count($notifAfterData['data'] ?? []);
    echo "Notifications count AFTER clear: {$notifAfterCount}\n";
    echo "Clear All Works: " . ($notifAfterCount === 0 ? "YES ✓" : "NO ✗") . "\n";
} else {
    echo "No notifications to clear\n";
}
