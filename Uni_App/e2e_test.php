<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

// Helper to make internal requests
function makeRequest($method, $uri, $user = null, $data = []) {
    global $app, $kernel;
    $request = Illuminate\Http\Request::create($uri, $method, $data);
    if ($user) {
        $app['auth']->guard('sanctum')->setUser($user);
    }
    $response = $kernel->handle($request);
    return json_decode($response->getContent(), true);
}

// 1. Get Users
$admin = App\Models\User::role('admin')->first();
$studentUser = App\Models\User::role('student')->first();
$staffUser = App\Models\User::role('student_affairs')->first();
$gradeStaff = App\Models\User::role('grade_control')->first();
$accountant = App\Models\User::role('accountant')->first();

echo "Users loaded.\n";

$results = [];

// Workflow 1: Student Login & Profile
$results['student_grades'] = makeRequest('GET', '/api/student/grades', $studentUser);
$results['student_payments'] = makeRequest('GET', '/api/student/payments', $studentUser);
$results['student_requests'] = makeRequest('GET', '/api/student/service-requests', $studentUser);
$results['student_appeals'] = makeRequest('GET', '/api/student/appeals', $studentUser);
$results['student_study_schedules'] = makeRequest('GET', '/api/student/study-schedules', $studentUser);

// Workflow 2: Admin/Staff Views
$results['admin_stats'] = makeRequest('GET', '/api/admin/stats', $admin);
$results['staff_requests'] = makeRequest('GET', '/api/staff/requests', $staffUser);
$results['staff_grades'] = makeRequest('GET', '/api/staff/grades', $gradeStaff);
$results['staff_appeals'] = makeRequest('GET', '/api/staff/appeals', $accountant);
$results['staff_study_schedules'] = makeRequest('GET', '/api/staff/study-schedules', $admin);

file_put_contents('e2e_results.json', json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
echo "Done saving to e2e_results.json\n";
