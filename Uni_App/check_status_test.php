<?php
// Quick test to check student status before/after suspension approval
require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Models\Request;
use App\Enums\RequestStatusEnum;
use App\Enums\StudentStatusEnum;

echo "=== STUDENT STATUS TEST ===\n\n";

// 1. Check all students and their statuses
$students = Student::with('user')->get();
foreach ($students as $student) {
    $statusVal = $student->status instanceof \App\Enums\StudentStatusEnum 
        ? $student->status->value 
        : (string)$student->status;
    echo "Student ID: {$student->id} | Name: {$student->user->name} | Status: {$statusVal}\n";
}

echo "\n=== SUSPENSION REQUESTS ===\n\n";

// 2. Check suspension requests
$reqs = Request::whereHas('requestType', function($q) {
    $q->where('slug', 'suspension_of_enrollment');
})->with(['student.user', 'requestType'])->get();

foreach ($reqs as $req) {
    $statusVal = $req->status instanceof RequestStatusEnum 
        ? $req->status->value 
        : (string)$req->status;
    $studentStatus = $req->student->status instanceof StudentStatusEnum 
        ? $req->student->status->value 
        : (string)$req->student->status;
    echo "Request ID: {$req->id} | Request Status: {$statusVal} | Student: {$req->student->user->name} | Student Status: {$studentStatus}\n";
}

echo "\n=== NOTIFICATIONS CHECK ===\n\n";

// 3. Check notifications count
$notifCount = \App\Models\Notification::count();
echo "Total notifications in DB: {$notifCount}\n";
