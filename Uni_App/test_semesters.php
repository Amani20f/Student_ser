<?php
// We will simulate API requests and output database state.

use App\Models\User;
use App\Models\Semester;
use App\Models\StudySchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

echo "=====================================\n";
echo "API VERIFICATION FOR SEMESTERS\n";
echo "=====================================\n\n";

// Login as admin
$admin = User::where('role', 'admin')->first();
auth()->login($admin);

function printRows($title) {
    echo "\n--- [ DATABASE STATE: $title ] ---\n";
    $semesters = Semester::all(['id', 'academic_year', 'term', 'is_active', 'start_date', 'end_date']);
    foreach ($semesters as $sem) {
        echo json_encode($sem->toArray()) . "\n";
    }
    echo "---------------------------------------\n";
}

printRows("INITIAL");

echo "\n1. Create a semester via POST /api/admin/semesters\n";
$request = Request::create('/api/admin/semesters', 'POST', [
    'start_year' => 2026,
    'end_year' => 2027,
    'term' => 'first',
    'start_date' => '2026-09-01',
    'end_date' => '2027-01-15',
    'exams_start_date' => '2027-01-01',
    'is_active' => false,
]);
$request->headers->set('Accept', 'application/json');
$response = app()->handle($request);
echo "Response Status: " . $response->getStatusCode() . "\n";
echo "Response Body: " . $response->getContent() . "\n";
$newSemesterData = json_decode($response->getContent(), true);
$newSemesterId = $newSemesterData['data']['id'] ?? null;
printRows("AFTER CREATE");

if ($newSemesterId) {
    echo "\n2. Edit the semester via PUT /api/admin/semesters/$newSemesterId\n";
    $request2 = Request::create("/api/admin/semesters/$newSemesterId", 'PUT', [
        'start_year' => 2026,
        'end_year' => 2027,
        'term' => 'second', // Changed term to 2
        'start_date' => '2026-09-01',
        'end_date' => '2027-01-15',
        'exams_start_date' => '2027-01-01',
        'is_active' => false,
    ]);
    $request2->headers->set('Accept', 'application/json');
    $response2 = app()->handle($request2);
    echo "Response Status: " . $response2->getStatusCode() . "\n";
    echo "Response Body: " . $response2->getContent() . "\n";
    printRows("AFTER EDIT");

    echo "\n3. Activate the semester via PUT /api/admin/semesters/$newSemesterId\n";
    $request3 = Request::create("/api/admin/semesters/$newSemesterId", 'PUT', [
        'start_year' => 2026,
        'end_year' => 2027,
        'term' => 'second',
        'start_date' => '2026-09-01',
        'end_date' => '2027-01-15',
        'exams_start_date' => '2027-01-01',
        'is_active' => true, // Activating
    ]);
    $request3->headers->set('Accept', 'application/json');
    $response3 = app()->handle($request3);
    echo "Response Status: " . $response3->getStatusCode() . "\n";
    echo "Response Body: " . $response3->getContent() . "\n";
    printRows("AFTER ACTIVATE");
}

echo "\n4. Call GET /api/semesters (Public endpoint)\n";
$request4 = Request::create('/api/semesters', 'GET');
$request4->headers->set('Accept', 'application/json');
$response4 = app()->handle($request4);
echo "Response Status: " . $response4->getStatusCode() . "\n";
echo "Response Body: " . $response4->getContent() . "\n";

echo "\n5. Verify active semester changed correctly\n";
$activeCount = Semester::where('is_active', true)->count();
$activeSem = Semester::where('is_active', true)->first();
echo "Total active semesters in DB: $activeCount\n";
if ($activeSem) {
    echo "Current Active Semester ID: {$activeSem->id} ({$activeSem->academic_year} Term {$activeSem->term->value})\n";
}

echo "\n6. Verify Study Schedules still resolve using the active semester\n";
$request5 = Request::create('/api/student/study-schedules', 'GET');
$request5->headers->set('Accept', 'application/json');
// We must use Sanctum::actingAs to properly authenticate for Spatie permissions
$student = User::where('role', 'student')->first();
if ($student) {
    \Laravel\Sanctum\Sanctum::actingAs($student, ['*']);
}
$response5 = app()->handle($request5);
echo "Response Status: " . $response5->getStatusCode() . "\n";
echo "Response Body: " . $response5->getContent() . "\n";

echo "\n=====================================\n";
echo "VERIFICATION COMPLETE\n";
echo "=====================================\n";
