<?php
require __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;

function runTestCase($kernel, $name, $certificateType, $gradePercentage, $programId, $programName, $expectedSuccess) {
    // Generate unique national ID and email to bypass Laravel unique validation
    $nationalId = 'TEST_' . rand(1000000000, 9999999999);
    $email = 'test_' . Str::random(8) . '@example.com';

    $request = Illuminate\Http\Request::create('/api/apply', 'POST', [
        'full_name' => 'Test Student',
        'national_id_number' => $nationalId,
        'date_of_birth' => '2000-01-01',
        'gender' => 'male',
        'nationality' => 'Yemeni',
        'phone_number' => '0500000000',
        'email_address' => $email,
        'address' => 'Sanaa',
        'desired_program_id' => $programId,
        'desired_academic_level' => '1',
        'certificate_type' => $certificateType,
        'grade_percentage' => $gradePercentage,
        'form_responses' => json_encode([
            'previous_major' => $certificateType,
            'grade_percentage' => $gradePercentage,
        ])
    ], [], [
        'identity_document'      => UploadedFile::fake()->create('id.pdf', 100, 'application/pdf'),
        'qualification_document' => UploadedFile::fake()->create('qual.pdf', 100, 'application/pdf'),
        'personal_photo'         => UploadedFile::fake()->image('photo.jpg', 200, 200),
    ]);

    $response = $kernel->handle($request);
    $status = $response->status();
    $content = json_decode($response->getContent(), true);
    
    $success = isset($content['success']) ? $content['success'] : false;
    $msg = isset($content['message']) ? $content['message'] : 'No message';

    echo "------------------------------------------------------------\n";
    echo "TEST CASE: $name\n";
    echo "Parameters: $certificateType | GPA: $gradePercentage% | Program: $programName (ID: $programId)\n";
    echo "Expected Success: " . ($expectedSuccess ? 'YES' : 'NO') . "\n";
    echo "API Response Status: $status\n";
    echo "API Success field: " . ($success ? 'YES' : 'NO') . "\n";
    echo "API Message: $msg\n";

    if ($success === $expectedSuccess) {
        echo "RESULT: PASSED\n";
    } else {
        echo "RESULT: FAILED\n";
    }
}

// 1. Scientific, 72%, applying for Civil Engineering (ID: 8) - Expected: FAIL (requires 75%)
runTestCase($kernel, "Scientific 72% for Civil Eng", "scientific", 72.0, 8, "الهندسة المدنية", false);

// 2. Scientific, 72%, applying for IT (ID: 4) - Expected: PASS (requires 70%)
runTestCase($kernel, "Scientific 72% for IT", "scientific", 72.0, 4, "تقنية المعلومات", true);

// 3. Literary, 85%, applying for IT (ID: 4) - Expected: FAIL (IT is scientific only)
runTestCase($kernel, "Literary 85% for IT", "literary", 85.0, 4, "تقنية المعلومات", false);

// 4. Literary, 85%, applying for Accounting (ID: 11) - Expected: PASS (Accounting is both, requires 60%)
runTestCase($kernel, "Literary 85% for Accounting", "literary", 85.0, 11, "المحاسبة", true);

// 5. Scientific, 55%, applying for Business (ID: 3) - Expected: FAIL (requires 60%)
runTestCase($kernel, "Scientific 55% for Business", "scientific", 55.0, 3, "إدارة الأعمال", false);

// 6. Scientific, 85%, applying for Medical (ID: 12) - Expected: FAIL (Medical is is_available = false)
runTestCase($kernel, "Scientific 85% for Medical GP", "scientific", 85.0, 12, "الطب العام والجراحة", false);

echo "------------------------------------------------------------\n";
