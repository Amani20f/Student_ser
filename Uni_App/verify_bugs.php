<?php

use App\Models\Request;
use App\Models\Notification;
use App\Models\StudentApplication;
use App\Models\User;
use App\Http\Controllers\Api\Staff\RequestController;
use App\Http\Controllers\Api\Admin\StudentApplicationManagementController;
use Illuminate\Support\Facades\DB;

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// 1. Verify Bug 1 (Duplicate Notifications)
echo "=== Testing Bug 1: Duplicate Notifications ===\n";

// Find an admin or staff user to act as
$staff = User::whereHas('roles', function($q) { $q->where('name', 'student_affairs'); })->first();
if (!$staff) {
    $staff = User::first();
}
auth()->login($staff);

// Get a request to approve
$request1 = Request::first();
if ($request1) {
    // Clear old notifications for this request
    Notification::where('related_id', $request1->id)->where('related_type', Request::class)->delete();

    // Mock an HTTP request for approve
    $httpReqApprove = Illuminate\Http\Request::create('/api/requests/' . $request1->id . '/status', 'PUT', [
        'status' => 'approved',
        'response_message' => 'Approved in test'
    ]);
    
    // Call controller
    $controller = app(RequestController::class);
    $controller->updateStatus($httpReqApprove, $request1->id);

    // Count notifications
    $notifCount = Notification::where('related_id', $request1->id)->where('related_type', Request::class)->count();
    echo "Approval Notification count (should be 1): $notifCount\n";
    $notif = Notification::where('related_id', $request1->id)->where('related_type', Request::class)->first();
    echo "Notification Message: " . ($notif ? $notif->message : 'None') . "\n";
} else {
    echo "No requests found to test approval.\n";
}

// Get another request to reject
$request2 = Request::orderBy('id', 'desc')->first();
if ($request2 && $request2->id !== $request1->id) {
    Notification::where('related_id', $request2->id)->where('related_type', Request::class)->delete();

    // Mock an HTTP request for reject
    $httpReqReject = Illuminate\Http\Request::create('/api/requests/' . $request2->id . '/status', 'PUT', [
        'status' => 'rejected',
        'response_message' => 'Rejected in test'
    ]);
    
    // Call controller
    $controller->updateStatus($httpReqReject, $request2->id);

    // Count notifications
    $notifCount = Notification::where('related_id', $request2->id)->where('related_type', Request::class)->count();
    echo "Rejection Notification count (should be 1): $notifCount\n";
} else {
    echo "Not enough requests to test rejection separately.\n";
}

// 2. Verify Bug 2 (Student Application Rejection Reason)
echo "\n=== Testing Bug 2: Student Application Rejection Reason ===\n";

$admin = User::whereHas('roles', function($q) { $q->where('name', 'admin'); })->first();
if (!$admin) {
    $admin = User::first();
}
auth()->login($admin);

// Create a dummy application if none exists
$appId = StudentApplication::insertGetId([
    'application_number' => 'APP-TEST-' . rand(1000, 9999),
    'application_status' => 'pending',
    'full_name' => 'Test User',
    'national_id_number' => 'NID-' . rand(1000, 9999),
    'date_of_birth' => '2000-01-01',
    'gender' => 'male',
    'nationality' => 'SA',
    'phone_number' => '12345678',
    'email_address' => 'test' . rand(100, 999) . '@example.com',
    'desired_program_id' => 1,
    'desired_academic_level' => 1,
    'created_at' => now(),
    'updated_at' => now(),
]);

$controller2 = app(StudentApplicationManagementController::class);
$httpReqAppReject = Illuminate\Http\Request::create('/api/admin/applications/' . $appId . '/reject', 'POST', [
    'rejection_reason' => 'Missing documents'
]);

// Call reject method
$response = $controller2->reject($httpReqAppReject, $appId);

// Check database
$appRecord = StudentApplication::find($appId);
echo "Rejection Reason in DB: " . ($appRecord->rejection_reason ?? 'NULL') . "\n";
echo "Response Status Code: " . $response->getStatusCode() . "\n";
$responseData = json_decode($response->getContent(), true);
echo "Response Rejection Reason: " . ($responseData['data']['rejection_reason'] ?? 'NOT IN RESPONSE') . "\n";

