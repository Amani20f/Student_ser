<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$students = App\Models\Student::with('program.department')->get();
$controller = new App\Http\Controllers\Api\Student\AcademicRecordController();

foreach ($students as $student) {
    $user = App\Models\User::find($student->user_id);
    if (!$user) continue;

    auth()->login($user);
    $request = Illuminate\Http\Request::create('/api/student/academic-record/results', 'GET');
    $response = $controller->results($request);
    $data = json_decode($response->getContent(), true);

    if (isset($data['error']) && $data['error'] === 'questionnaire_required') {
        echo "Student " . $student->id . " (Program " . $student->program_id . ", College " . $student->program->department->college_id . "): Blocked by Survey " . $data['survey']['id'] . " - " . $data['survey']['title'] . "\n";
    } else {
        echo "Student " . $student->id . " (Program " . $student->program_id . ", College " . $student->program->department->college_id . "): Not blocked (Grades returned)\n";
    }
}
