<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Student;
use App\Models\Request as StudentRequest;
use App\Models\Payment;
use App\Models\Appeal;
use App\Models\Notification;
use App\Models\ActivityLog;
use App\Models\Survey;
use App\Models\Announcement;
use App\Models\StudyPlan;
use App\Models\StudySchedule;

echo "=== STAFF ACCOUNTS ===\n";
$staff = User::whereNot('role', 'student')->get();
foreach ($staff as $s) {
    echo "- ID: {$s->id}, Name: {$s->name}, Email: {$s->email}, Role: {$s->role}\n";
}

echo "\n=== STUDENT ACCOUNTS ===\n";
$students = Student::with('user')->get();
foreach ($students as $st) {
    $u = $st->user;
    $statusStr = is_object($st->status) && isset($st->status->value) ? $st->status->value : (string)$st->status;
    echo "- Student ID: {$st->id}, User ID: " . ($u ? $u->id : 'N/A') . ", Name: " . ($u ? $u->name : 'N/A') . ", Num: {$st->student_number}, GPA: {$st->cumulative_gpa}, Status: {$statusStr}\n";
}

echo "\n=== REQUESTS ===\n";
$requests = StudentRequest::all();
echo "Total Requests: " . $requests->count() . "\n";
foreach ($requests as $r) {
    echo "- ID: {$r->id}, Type ID: {$r->request_type_id}, Status: {$r->status}, Form: " . json_encode($r->form_data) . "\n";
}

echo "\n=== PAYMENTS ===\n";
$payments = Payment::all();
echo "Total Payments: " . $payments->count() . "\n";

echo "\n=== APPEALS / GRIEVANCES ===\n";
$appeals = Appeal::all();
echo "Total Appeals: " . $appeals->count() . "\n";

echo "\n=== NOTIFICATIONS ===\n";
$notifications = Notification::all();
echo "Total Notifications: " . $notifications->count() . "\n";

echo "\n=== SURVEYS ===\n";
$surveys = Survey::all();
echo "Total Surveys: " . $surveys->count() . "\n";
foreach ($surveys as $sv) {
    echo "- ID: {$sv->id}, Title: {$sv->title}, Active: {$sv->is_active}\n";
}

echo "\n=== ANNOUNCEMENTS ===\n";
$announcements = Announcement::all();
echo "Total Announcements: " . $announcements->count() . "\n";
foreach ($announcements as $an) {
    echo "- ID: {$an->id}, Title: {$an->title}, Active: {$an->is_active}\n";
}

echo "\n=== STUDY PLANS ===\n";
$plans = StudyPlan::all();
echo "Total Study Plans: " . $plans->count() . "\n";

echo "\n=== STUDY SCHEDULES ===\n";
$schedules = StudySchedule::all();
echo "Total Study Schedules: " . $schedules->count() . "\n";
