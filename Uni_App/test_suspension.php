<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Student;
use App\Models\Request;

$user = User::factory()->create();
$student = Student::create([
    'user_id' => $user->id,
    'national_id' => '200000' . rand(1000, 9999),
    'student_number' => '2026' . rand(1000, 9999),
    'phone' => '050' . rand(1000000, 9999999),
    'full_name_ar' => 'Test Student',
    'full_name_en' => 'Test Student',
    'status' => 'active',
    'program_id' => 2,
    'academic_level' => 3
]);

$request = Request::create([
    'student_id' => $student->id,
    'request_type' => 'suspension',
    'status' => 'pending',
    'reason' => 'Test',
    'semester' => 'first',
    'academic_year' => '2026'
]);

echo "Initial Status: " . $request->status . "\n";
echo "Initial Student Status: " . $student->status . "\n";

// Ratified by accountant
$request->update(['status' => 'ratified', 'accountant_notes' => 'Ratified ok']);
echo "After Accountant: " . $request->status . "\n";

// Approved by Student Affairs
// Emulate the controller logic
$request->update(['status' => 'approved', 'admin_notes' => 'Approved ok']);
$student->update(['status' => 'suspended']);

echo "After SA: " . $request->status . "\n";
echo "Final Student Status: " . $student->status . "\n";
