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
use App\Models\AppealItem;
use App\Models\Notification;
use App\Models\ActivityLog;
use App\Models\Survey;
use App\Models\Announcement;
use App\Models\StudyPlan;
use App\Models\StudySchedule;
use App\Models\Grade;
use Illuminate\Support\Facades\DB;

// IDs to KEEP
$keepStaffUserIds = [1, 2, 3, 4, 21];
$keepStudentUserIds = [7, 29, 14, 8, 18, 20, 5]; // corresponding to student IDs: 3, 23, 10, 4, 13, 15, 1
$allKeepUserIds = array_merge($keepStaffUserIds, $keepStudentUserIds);

echo "Starting presentation cleanup...\n";

// Count stats before
$statsBefore = [
    'users' => User::count(),
    'students' => Student::count(),
    'requests' => StudentRequest::count(),
    'payments' => Payment::count(),
    'appeals' => Appeal::count(),
    'notifications' => Notification::count(),
    'activity_logs' => ActivityLog::count(),
    'surveys' => Survey::count(),
    'announcements' => Announcement::count(),
    'study_plans' => StudyPlan::count(),
    'study_schedules' => StudySchedule::count(),
];

// Perform cleanup inside a database transaction to ensure safety
DB::beginTransaction();

try {
    $keepStudentIds = Student::whereIn('user_id', $keepStudentUserIds)->pluck('id')->toArray();
    $keepStudentUserIdsActual = Student::whereIn('user_id', $keepStudentUserIds)->pluck('user_id')->toArray();

    // 1. Delete Students and Users NOT in the keep lists
    $usersToDelete = User::whereNotIn('id', $allKeepUserIds)->get();
    $studentsToDelete = Student::whereNotIn('id', $keepStudentIds)->get();

    echo "Deleting " . $studentsToDelete->count() . " student records and " . $usersToDelete->count() . " user records...\n";

    // Delete associated appeal items and appeals for deleted students first
    $deletedAppeals = Appeal::whereNotIn('student_id', $keepStudentIds)->get();
    foreach ($deletedAppeals as $ap) {
        AppealItem::where('appeal_id', $ap->id)->delete();
        Payment::where('appeal_id', $ap->id)->delete();
        $ap->delete();
    }
    echo "Deleted " . $deletedAppeals->count() . " old appeal records and their items.\n";

    // Delete associated grades for deleted students
    $deletedGradesCount = Grade::whereNotIn('student_id', $keepStudentIds)->delete();
    echo "Deleted $deletedGradesCount grade records.\n";

    // Delete request payments first
    $deletedRequests = StudentRequest::whereNotIn('student_id', $keepStudentUserIdsActual)->get();
    foreach ($deletedRequests as $req) {
        Payment::where('request_id', $req->id)->delete();
        $req->delete();
    }
    echo "Deleted " . $deletedRequests->count() . " old request records and their payments.\n";

    // Delete student records
    Student::whereNotIn('id', $keepStudentIds)->delete();

    // Delete notification user pivots that belong to deleted users
    DB::table('notification_user')->whereNotIn('user_id', $allKeepUserIds)->delete();

    // Delete user records
    User::whereNotIn('id', $allKeepUserIds)->delete();

    // 2. Clean up Requests & Payments for the REMAINING users
    // Keep only realistic/meaningful requests: Keep at most 2 requests per remaining student
    foreach ($keepStudentUserIdsActual as $uid) {
        $studentReqs = StudentRequest::where('student_id', $uid)->orderBy('created_at', 'desc')->get();
        if ($studentReqs->count() > 2) {
            $toDelete = $studentReqs->skip(2);
            foreach ($toDelete as $td) {
                Payment::where('request_id', $td->id)->delete();
                $td->delete();
            }
            echo "Cleaned up excess/old requests for Student User ID $uid.\n";
        }
    }

    // Keep at most 2 appeals per remaining student
    foreach ($keepStudentIds as $sid) {
        $studentAppeals = Appeal::where('student_id', $sid)->orderBy('created_at', 'desc')->get();
        if ($studentAppeals->count() > 2) {
            $toDelete = $studentAppeals->skip(2);
            foreach ($toDelete as $td) {
                AppealItem::where('appeal_id', $td->id)->delete();
                Payment::where('appeal_id', $td->id)->delete();
                $td->delete();
            }
            echo "Cleaned up excess/old appeals for Student ID $sid.\n";
        }
    }

    // 3. Payments cleanup: Remove orphan payments or failed payments
    Payment::whereNotIn('status', ['pending', 'verified', 'rejected'])->delete();
    // Also delete payments for deleted requests or appeals
    Payment::whereNull('request_id')->whereNull('appeal_id')->delete();

    // 4. Notifications cleanup: Remove notifications that have no users linked to them
    DB::table('notifications')->whereNotExists(function ($query) {
        $query->select(DB::raw(1))
              ->from('notification_user')
              ->whereColumn('notification_user.notification_id', 'notifications.id');
    })->delete();

    // 5. Activity Logs cleanup: Delete old logs, keep only last 20 logs
    $keepLogIds = ActivityLog::orderBy('created_at', 'desc')->limit(20)->pluck('id');
    ActivityLog::whereNotIn('id', $keepLogIds)->delete();

    // 6. Surveys cleanup
    $surveys = Survey::all();
    foreach ($surveys as $sv) {
        if (str_contains(strtolower($sv->title), 'test') || str_contains($sv->title, 'تجربة') || empty($sv->title)) {
            $sv->delete();
            echo "Deleted test survey: {$sv->title}\n";
        }
    }
    if (Survey::count() == 0) {
        Survey::create([
            'title' => 'استبيان تقييم الخدمات الطلابية',
            'description' => 'يسر عمادة شؤون الطلاب قياس مدى رضاكم عن الخدمات المقدمة عبر البوبة الإلكترونية.',
            'google_form_url' => 'https://docs.google.com/forms/d/e/1FAIpQLSfD5g9X/viewform',
            'is_active' => true,
            'is_required_for_grades' => false,
            'target_college_id' => null,
            'target_program_id' => null,
            'target_level' => null,
        ]);
        echo "Created a professional demo survey.\n";
    }

    // 7. Announcements cleanup
    $announcements = Announcement::all();
    foreach ($announcements as $an) {
        if (str_contains(strtolower($an->title), 'test') || str_contains($an->title, 'تجربة') || empty($an->title)) {
            $an->delete();
            echo "Deleted test announcement: {$an->title}\n";
        }
    }
    if (Announcement::count() == 0) {
        Announcement::create([
            'title' => 'بدء تسجيل المقررات للفصل الدراسي الجديد',
            'content' => 'نود إحاطة جميع الطلاب بأن فترة التسجيل للفصل الدراسي القادم ستبدأ يوم الأحد القادم عبر البوابة.',
            'target_audience' => 'all_students',
            'is_active' => true,
            'published_at' => now(),
        ]);
        echo "Created a professional demo announcement.\n";
    }

    DB::commit();
    echo "Cleanup committed successfully!\n";

} catch (\Exception $e) {
    DB::rollBack();
    echo "Error during cleanup: " . $e->getMessage() . "\n";
    exit(1);
}

// Count stats after
$statsAfter = [
    'users' => User::count(),
    'students' => Student::count(),
    'requests' => StudentRequest::count(),
    'payments' => Payment::count(),
    'appeals' => Appeal::count(),
    'notifications' => Notification::count(),
    'activity_logs' => ActivityLog::count(),
    'surveys' => Survey::count(),
    'announcements' => Announcement::count(),
    'study_plans' => StudyPlan::count(),
    'study_schedules' => StudySchedule::count(),
];

echo "\n=== CLEANUP SUMMARY ===\n";
foreach ($statsBefore as $key => $val) {
    $removed = $val - $statsAfter[$key];
    echo "- " . ucfirst(str_replace('_', ' ', $key)) . ": Before = $val, After = {$statsAfter[$key]}, Removed = $removed\n";
}

echo "\n=== RETAINED STAFF ACCOUNTS ===\n";
$staff = User::whereNot('role', 'student')->get();
foreach ($staff as $s) {
    echo "- Name: {$s->name}, Email: {$s->email}, Role: {$s->role}\n";
}

echo "\n=== RETAINED STUDENT ACCOUNTS ===\n";
$students = Student::with('user')->get();
foreach ($students as $st) {
    $u = $st->user;
    $statusStr = is_object($st->status) && isset($st->status->value) ? $st->status->value : (string)$st->status;
    echo "- Name: " . ($u ? $u->name : 'N/A') . ", Num: {$st->student_number}, GPA: {$st->cumulative_gpa}, Status: {$statusStr}\n";
}
