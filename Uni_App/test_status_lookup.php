<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$app = \App\Models\StudentApplication::where('application_number', 'APP-2026-496E6A')->first();
echo "1. Status Lookup (Pending):\n";
echo file_get_contents('http://127.0.0.1:8000/api/apply/status/1000000011') . "\n";

$app->update(['application_status' => 'rejected', 'rejection_reason' => 'Missing document translation']);
echo "2. Status Lookup (Rejected):\n";
echo file_get_contents('http://127.0.0.1:8000/api/apply/status/1000000011') . "\n";

$app->update(['application_status' => 'completed']);
\App\Models\Student::create([
    'national_id' => '1000000011',
    'student_number' => '20269999',
    'full_name_ar' => 'Test', 'full_name_en' => 'Test',
    'status' => 'active', 'program_id' => 2, 'academic_level' => 1
]);
echo "3. Status Lookup (Approved):\n";
echo file_get_contents('http://127.0.0.1:8000/api/apply/status/1000000011') . "\n";
