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

$nationalId = '9999999999';
$email = 'e2e_choices_test@university.edu';

echo "Cleaning up existing test data...\n";
DB::transaction(function () use ($nationalId, $email) {
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
});

echo "Step 1: Creating student application with 3 preferences...\n";
$storeController = app(StudentApplicationController::class);
$request = Request::create('/api/apply', 'POST', [
    'full_name' => 'E2E Choices Student',
    'national_id_number' => $nationalId,
    'date_of_birth' => '2004-05-15',
    'gender' => 'female',
    'nationality' => 'اليمن',
    'phone_number' => '+967777777777',
    'email_address' => $email,
    'address' => 'صنعاء، اليمن',
    'desired_program_id' => 8, // legacy field
    'first_choice_program_id' => 8, // Civil Eng (ID 8, Scientific, 75%)
    'second_choice_program_id' => 6, // Cyber Security (ID 6, Scientific, 70%)
    'third_choice_program_id' => 11, // Accounting (ID 11, Both, 60%)
    'desired_academic_level' => 1,
    'certificate_type' => 'scientific',
    'grade_percentage' => 82.5,
]);

// Set fake documents
$pdfFile = \Illuminate\Http\UploadedFile::fake()->create('document.pdf', 100);
$jpegFile = \Illuminate\Http\UploadedFile::fake()->create('photo.jpg', 100);
$request->files->set('identity_document', $pdfFile);
$request->files->set('qualification_document', $pdfFile);
$request->files->set('personal_photo', $jpegFile);
$request->files->set('payment_receipt', $pdfFile);

try {
    $response = $storeController->store($request);
    $data = $response->getData(true);
    echo "Store Response Status: " . $response->getStatusCode() . "\n";
    echo "Store Response Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    if (!$data['success']) {
        echo "Error message: " . ($data['message'] ?? 'N/A') . "\n";
        exit(1);
    }
    $appNumber = $data['application_number'];
    echo "Created Application Number: " . $appNumber . "\n";

    // Query application from DB
    $application = StudentApplication::where('application_number', $appNumber)->firstOrFail();
    echo "\nSaved DB Application Choices:\n";
    echo "  First Choice ID: " . $application->first_choice_program_id . " (" . $application->firstChoiceProgram?->name . ")\n";
    echo "  Second Choice ID: " . $application->second_choice_program_id . " (" . $application->secondChoiceProgram?->name . ")\n";
    echo "  Third Choice ID: " . $application->third_choice_program_id . " (" . $application->thirdChoiceProgram?->name . ")\n";
    echo "  Approved Program ID: " . ($application->approved_program_id ?? 'NULL') . "\n";

    echo "\nStep 2: Admin approves Second Choice (ID 6 - Cybersecurity)...\n";
    $adminController = app(StudentApplicationManagementController::class);
    $approveRequest = Request::create("/api/admin/applications/{$application->id}/approve", 'POST', [
        'approved_program_id' => 6
    ]);
    
    $approveResponse = $adminController->approve($approveRequest, $application->id);
    $approveData = $approveResponse->getData(true);
    echo "Approve Response Status: " . $approveResponse->getStatusCode() . "\n";
    echo "Approve Response Success: " . ($approveData['success'] ? 'YES' : 'NO') . "\n";
    echo "Approve Response Message: " . ($approveData['message'] ?? 'N/A') . "\n";

    // Reload application
    $application->refresh();
    echo "\nPost-Approval DB Application Status:\n";
    echo "  Status: " . $application->application_status . "\n";
    echo "  Approved Program ID: " . ($application->approved_program_id ?? 'NULL') . " (" . $application->approvedProgram?->name . ")\n";

    // Check Student record
    $student = Student::where('national_id', $nationalId)->firstOrFail();
    echo "\nGenerated Student Record:\n";
    echo "  Student Number: " . $student->student_number . "\n";
    echo "  Program ID: " . $student->program_id . " (" . $student->program?->name . ")\n";
    
    // Assert and prove
    if ($student->program_id == 6) {
        echo "\nE2E TEST RESULT: SUCCESS - Student is successfully registered in the second choice (Cybersecurity)\n";
    } else {
        echo "\nE2E TEST RESULT: FAILED - Student program ID is " . $student->program_id . " instead of 6\n";
    }

} catch (\Exception $e) {
    echo "E2E Exception: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
