<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

function testStudentAPI($studentId, $roleName) {
    echo "Testing $roleName (Student $studentId)\n";
    $student = App\Models\Student::find($studentId);
    $user = App\Models\User::find($student->user_id);
    
    auth()->login($user);
    $request = Illuminate\Http\Request::create('/api/student/grades', 'GET');
    
    // GradeController has constructor injection for StudentService.
    $controller = app()->make(App\Http\Controllers\Api\Student\GradeController::class);
    $response = $controller->index($request);
    
    $data = json_decode($response->getContent(), true);
    
    if (isset($data['requires_survey']) && $data['requires_survey'] == true) {
        echo "=> BLOCKED BY SURVEY ID: " . $data['survey']['id'] . " (" . $data['survey']['title'] . ")\n\n";
    } else {
        echo "=> NOT BLOCKED. Grades returned.\n\n";
    }
}

testStudentAPI(1, 'Computer Science');
testStudentAPI(10, 'Business Administration');
