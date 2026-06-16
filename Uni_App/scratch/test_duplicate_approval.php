<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\StudentApplication;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\StudentApplicationController;
use App\Http\Controllers\Api\Admin\StudentApplicationManagementController;
use Illuminate\Support\Facades\DB;

$nationalId = '9999991111';
$email = 'dup_test@university.edu';

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

echo "Cleaning up existing test data...\n";
cleanTestData($nationalId, $email);

echo "\nStep 1: Submitting student application...\n";
$storeController = app(StudentApplicationController::class);
$request = Request::create('/api/apply', 'POST', [
    'full_name' => 'Duplicate Approval Test Student',
    'national_id_number' => $nationalId,
    'date_of_birth' => '2004-05-15',
    'gender' => 'male',
    'nationality' => 'اليمن',
    'phone_number' => '+967777777777',
    'email_address' => $email,
    'address' => 'صنعاء، اليمن',
    'desired_program_id' => 4,
    'first_choice_program_id' => 4, // IT (requires 70%)
    'second_choice_program_id' => 5, // AI (requires 70%)
    'third_choice_program_id' => 11, // Accounting
    'desired_academic_level' => 1,
    'certificate_type' => 'scientific',
    'grade_percentage' => 80.0,
]);

// Set fake documents
$pdfFile = \Illuminate\Http\UploadedFile::fake()->create('document.pdf', 100);
$jpegFile = \Illuminate\Http\UploadedFile::fake()->create('photo.jpg', 100);
$request->files->set('identity_document', $pdfFile);
$request->files->set('qualification_document', $pdfFile);
$request->files->set('personal_photo', $jpegFile);

try {
    $response = $storeController->store($request);
    $data = $response->getData(true);
    echo "Application Store Status: " . $response->getStatusCode() . "\n";
    $appId = StudentApplication::where('national_id_number', $nationalId)->value('id');

    echo "\nStep 2: Sending first approval request...\n";
    $adminController = app(StudentApplicationManagementController::class);
    $approveRequest1 = Request::create("/api/admin/applications/{$appId}/approve", 'POST', [
        'approved_program_id' => 4
    ]);
    
    $response1 = $adminController->approve($approveRequest1, $appId);
    $data1 = $response1->getData(true);
    echo "First Approval Status: " . $response1->getStatusCode() . "\n";
    echo "First Approval Success: " . ($data1['success'] ? 'YES' : 'NO') . "\n";
    echo "First Approval Message: " . ($data1['message'] ?? 'N/A') . "\n";

    echo "\nStep 3: Sending duplicate approval request...\n";
    $approveRequest2 = Request::create("/api/admin/applications/{$appId}/approve", 'POST', [
        'approved_program_id' => 5
    ]);
    
    $response2 = $adminController->approve($approveRequest2, $appId);
    $data2 = $response2->getData(true);
    echo "Second Approval Status: " . $response2->getStatusCode() . "\n";
    echo "Second Approval Success: " . ($data2['success'] ? 'YES' : 'NO') . "\n";
    echo "Second Approval Message: " . ($data2['message'] ?? 'N/A') . "\n";

    // Verify database counts
    $studentCount = Student::where('national_id', $nationalId)->count();
    echo "\nDatabase Verification:\n";
    echo "  Student Account Count: " . $studentCount . "\n";
    
    if ($response2->getStatusCode() == 422 && $studentCount == 1) {
        echo "\nRESULT: PASSED (Duplicate approval successfully blocked on backend)\n";
    } else {
        echo "\nRESULT: FAILED\n";
    }

} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}

cleanTestData($nationalId, $email);
