<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Http\Request;
use App\Http\Controllers\Api\StudentApplicationController;

$controller = app(StudentApplicationController::class);

echo "--- Running Choice Eligibility Test ---\n";
echo "Testing: Literary Stream Student, 65.00% GPA.\n";
echo "  1st Choice: Accounting (ID 11 - Eligible)\n";
echo "  2nd Choice: Civil Eng (ID 8 - Ineligible: Scientific only & requires 75%)\n";
echo "  3rd Choice: Business (ID 3 - Eligible)\n\n";

$request = Request::create('/api/apply', 'POST', [
    'full_name' => 'Test Eligibility Student',
    'national_id_number' => '8888888888',
    'date_of_birth' => '2004-05-15',
    'gender' => 'male',
    'nationality' => 'اليمن',
    'phone_number' => '+967777777777',
    'email_address' => 'eligibility_test@university.edu',
    'address' => 'صنعاء، اليمن',
    'desired_program_id' => 11,
    'first_choice_program_id' => 11, // Accounting
    'second_choice_program_id' => 8, // Civil Eng (Invalid for literary student)
    'third_choice_program_id' => 3,  // Business
    'desired_academic_level' => 1,
    'certificate_type' => 'literary',
    'grade_percentage' => 65.0,
]);

// Set fake documents
$pdfFile = \Illuminate\Http\UploadedFile::fake()->create('document.pdf', 100);
$jpegFile = \Illuminate\Http\UploadedFile::fake()->create('photo.jpg', 100);
$request->files->set('identity_document', $pdfFile);
$request->files->set('qualification_document', $pdfFile);
$request->files->set('personal_photo', $jpegFile);

try {
    $response = $controller->store($request);
    $data = $response->getData(true);
    echo "API Response Status: " . $response->getStatusCode() . "\n";
    echo "API Response Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    echo "API Response Message: " . ($data['message'] ?? 'N/A') . "\n";
} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
