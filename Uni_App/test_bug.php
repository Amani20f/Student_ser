<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$student = App\Models\Student::with('program.department')->where('student_number', 'S202600000')->first();
echo "--- STUDENT DATA ---\n";
echo "Student ID: " . $student->id . "\n";
echo "Program ID: " . $student->program_id . "\n";
echo "College ID: " . $student->program->department->college_id . "\n";
echo "Current Level: " . $student->current_level . "\n\n";

$survey = App\Models\Survey::where('title', 'لطلاب الاداره')->first();
echo "--- SURVEY DATA ---\n";
echo "Survey ID: " . ($survey ? $survey->id : "NOT FOUND") . "\n";
if ($survey) {
    echo "target_college_id: " . var_export($survey->target_college_id, true) . "\n";
    echo "target_program_id: " . var_export($survey->target_program_id, true) . "\n";
    echo "target_level: " . var_export($survey->target_level, true) . "\n\n";
}

echo "--- FILTERING TRACE ---\n";
if ($survey) {
    $c_match = ($survey->target_college_id === null || $survey->target_college_id == $student->program->department->college_id);
    $p_match = ($survey->target_program_id === null || $survey->target_program_id == $student->program_id);
    $l_match = ($survey->target_level === null || $survey->target_level == $student->current_level);
    
    echo "College Match (Null OR " . var_export($survey->target_college_id, true) . " == " . $student->program->department->college_id . "): " . ($c_match ? "TRUE" : "FALSE") . "\n";
    echo "Program Match (Null OR " . var_export($survey->target_program_id, true) . " == " . $student->program_id . "): " . ($p_match ? "TRUE" : "FALSE") . "\n";
    echo "Level Match (Null OR " . var_export($survey->target_level, true) . " == " . $student->current_level . "): " . ($l_match ? "TRUE" : "FALSE") . "\n";
    
    $overall = $c_match && $p_match && $l_match;
    echo "Overall SQL Match expected: " . ($overall ? "TRUE" : "FALSE") . "\n\n";
}

echo "--- ACTUAL API BEHAVIOR ---\n";
$user = App\Models\User::find($student->user_id);
auth()->login($user);

$controller = new App\Http\Controllers\Api\Student\AcademicRecordController();
$request = Illuminate\Http\Request::create('/api/student/academic-record/results', 'GET');
$response = $controller->results($request);

echo "RESPONSE JSON:\n";
echo json_encode(json_decode($response->getContent()), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
