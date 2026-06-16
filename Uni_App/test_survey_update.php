<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$survey = \App\Models\Survey::first();
if ($survey) {
    $request = \Illuminate\Http\Request::create('/api/staff/surveys/' . $survey->id, 'PUT', [
        'title' => 'Test',
        'google_form_url' => 'http://google.com',
        'is_active' => true,
        'is_required_for_grades' => true,
        'target_college_id' => null,
        'target_program_id' => null,
        'target_level' => null,
    ]);
    
    $controller = app(\App\Http\Controllers\Api\Admin\SurveyController::class);
    try {
        $response = $controller->update($request, $survey);
        echo "Status: " . $response->getStatusCode() . "\n";
        echo "Response: " . $response->getContent() . "\n";
    } catch (\Exception $e) {
        echo 'Error: ' . $e->getMessage() . "\n";
    }
} else {
    echo "No survey found\n";
}
