<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Http\Request;
use App\Http\Controllers\Api\StudentApplicationController;
use App\Models\StudentApplication;
use App\Models\User;
use App\Models\Student;
use Illuminate\Support\Facades\DB;

$controller = app(StudentApplicationController::class);

// Clean up helper
function cleanTestData($nationalId, $email) {
    $apps = StudentApplication::where('national_id_number', $nationalId)->get();
    foreach ($apps as $app) {
        $student = Student::where('national_id', $nationalId)->first();
        if ($student) {
            $userId = $student->user_id;
            $student->delete();
            User::where('id', $userId)->delete();
        }
        $app->delete();
    }
    User::where('email', $email)->delete();
}

function runTestCase($controller, $caseNum, $desc, $certType, $gpa, $firstChoice, $secondChoice, $thirdChoice, $expectedSuccess, $expectedErrorReason = null) {
    echo "=================================================================\n";
    echo "TEST CASE {$caseNum}: {$desc}\n";
    echo "  Certificate: {$certType} | GPA: {$gpa}%\n";
    echo "  1st Choice ID: " . ($firstChoice ?: 'NULL') . "\n";
    echo "  2nd Choice ID: " . ($secondChoice ?: 'NULL') . "\n";
    echo "  3rd Choice ID: " . ($thirdChoice ?: 'NULL') . "\n";
    echo "  Expected Success: " . ($expectedSuccess ? "YES" : "NO") . "\n";
    
    $nationalId = '999999000' . $caseNum;
    $email = "test_case_{$caseNum}@university.edu";
    cleanTestData($nationalId, $email);

    $params = [
        'full_name' => "Student Case {$caseNum}",
        'national_id_number' => $nationalId,
        'date_of_birth' => '2004-05-15',
        'gender' => 'male',
        'nationality' => 'سعودي',
        'phone_number' => '050000000' . $caseNum,
        'email_address' => $email,
        'address' => 'Test Address',
        'desired_program_id' => $firstChoice,
        'first_choice_program_id' => $firstChoice,
        'desired_academic_level' => 1,
        'certificate_type' => $certType,
        'grade_percentage' => $gpa,
    ];

    if ($secondChoice !== null) $params['second_choice_program_id'] = $secondChoice;
    if ($thirdChoice !== null) $params['third_choice_program_id'] = $thirdChoice;

    $request = Request::create('/api/apply', 'POST', $params);

    $pdfFile = \Illuminate\Http\UploadedFile::fake()->create('document.pdf', 100);
    $jpegFile = \Illuminate\Http\UploadedFile::fake()->create('photo.jpg', 100);
    $request->files->set('identity_document', $pdfFile);
    $request->files->set('qualification_document', $pdfFile);
    $request->files->set('personal_photo', $jpegFile);

    try {
        $response = $controller->store($request);
        $data = $response->getData(true);
        $status = $response->getStatusCode();
        
        $success = ($status === 201);
        echo "  Actual Status: {$status}\n";
        echo "  Actual Success: " . ($success ? "YES" : "NO") . "\n";
        if (!$success) {
            echo "  Error Message: " . ($data['message'] ?? json_encode($data)) . "\n";
        }
        
        if ($success === $expectedSuccess) {
            echo "  RESULT: PASSED\n";
        } else {
            echo "  RESULT: FAILED\n";
        }
    } catch (\Illuminate\Validation\ValidationException $e) {
        $errors = $e->validator->errors()->all();
        $errorMsg = implode(', ', $errors);
        echo "  Actual Status: 422 (ValidationException)\n";
        echo "  Actual Success: NO\n";
        echo "  Validation Errors: {$errorMsg}\n";
        
        $matched = false;
        if (!$expectedSuccess) {
            if ($expectedErrorReason === 'third_choice_required' && str_contains($errorMsg, 'third choice program id')) {
                $matched = true;
            } elseif ($expectedErrorReason === 'second_choice_required' && str_contains($errorMsg, 'second choice program id')) {
                $matched = true;
            }
        }
        
        if ($matched || (!$expectedSuccess && $expectedErrorReason === null)) {
            echo "  RESULT: PASSED\n";
        } else {
            echo "  RESULT: FAILED\n";
        }
    } catch (\Exception $e) {
        echo "  Exception: " . $e->getMessage() . "\n";
        echo "  RESULT: FAILED\n";
    }
    cleanTestData($nationalId, $email);
}

// Count programs available in DB to double check
$allPrograms = \App\Models\Program::where('is_available', true)->get();
echo "Active Phase 1 programs in DB:\n";
foreach ($allPrograms as $p) {
    echo "  - ID {$p->id}: {$p->name} | stream: {$p->certificate_type} | min %: {$p->minimum_percentage}\n";
}
echo "\n";

// Test 1: Literary 85% -> Eligible Programs = 2 (Accounting & Business) -> Required Preferences = 2
// Sending only 2 choices. Should succeed (status 201).
runTestCase($controller, 1, "Literary 85% (Requires 2 preferences, sending 2)", "literary", 85.0, 11, 3, null, true);

// Test 2: Scientific 72% -> Eligible Programs >= 3 (IT, AI, Cyber, Accounting, Business) -> Required Preferences = 3
// Sending only 2 choices. Should fail validation on missing third choice.
runTestCase($controller, 2, "Scientific 72% (Requires 3 preferences, sending 2)", "scientific", 72.0, 4, 5, null, false, 'third_choice_required');

// Test 3: Scientific 65% -> Eligible Programs = 2 (Accounting & Business) -> Required Preferences = 2
// Sending only 2 choices. Should succeed (status 201).
runTestCase($controller, 3, "Scientific 65% (Requires 2 preferences, sending 2)", "scientific", 65.0, 11, 3, null, true);
