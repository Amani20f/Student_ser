<?php
require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Http;
use Illuminate\Http\UploadedFile;

function createDummyFile($ext, $content) {
    $path = sys_get_temp_dir() . '/dummy.' . $ext;
    file_put_contents($path, $content);
    return $path;
}

$pdfPath = createDummyFile('pdf', "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\ntrailer\n<<\n/Root 1 0 R\n>>\n%%EOF");
$jpgPath = createDummyFile('jpg', "\xFF\xD8\xFF\xE0\x00\x10\x4A\x46\x49\x46\x00\x01\x01\x01\x00\x60\x00\x60\x00\x00\xFF\xDB\x00\x43\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\x09");
$pngPath = createDummyFile('png', "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\x0A\x49\x44\x41\x54\x78\x9C\x63\x00\x01\x00\x00\x05\x00\x01\x0D\x0A\x2D\xB4\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82");

$baseUrl = 'http://127.0.0.1:8000/api/apply';

echo "--- 1. Testing PDF Upload ---\n";
$response = Http::attach('identity_document', file_get_contents($pdfPath), 'test.pdf')
    ->attach('qualification_document', file_get_contents($pdfPath), 'test.pdf')
    ->attach('personal_photo', file_get_contents($jpgPath), 'test.jpg') // photo is always img usually
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000000', 'email_address' => 'pdf@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_program_id' => '2', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";

echo "\n--- 2. Testing JPG Upload ---\n";
$response = Http::attach('identity_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('qualification_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('personal_photo', file_get_contents($jpgPath), 'test.jpg')
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000001', 'email_address' => 'jpg@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_program_id' => '2', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";

echo "\n--- 3. Testing PNG Upload ---\n";
$response = Http::attach('identity_document', file_get_contents($pngPath), 'test.png')
    ->attach('qualification_document', file_get_contents($pngPath), 'test.png')
    ->attach('personal_photo', file_get_contents($pngPath), 'test.png')
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000002', 'email_address' => 'png@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_program_id' => '2', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";

echo "\n--- 4. Testing Duplicate National ID ---\n";
$response = Http::attach('identity_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('qualification_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('personal_photo', file_get_contents($jpgPath), 'test.jpg')
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000001', 'email_address' => 'dup@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_program_id' => '2', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";

echo "\n--- 5. Testing Duplicate Email ---\n";
$response = Http::attach('identity_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('qualification_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('personal_photo', file_get_contents($jpgPath), 'test.jpg')
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000005', 'email_address' => 'jpg@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_program_id' => '2', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";

echo "\n--- 6. Testing Missing Major ---\n";
$response = Http::attach('identity_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('qualification_document', file_get_contents($jpgPath), 'test.jpg')
    ->attach('personal_photo', file_get_contents($jpgPath), 'test.jpg')
    ->post($baseUrl, [
        'first_name_ar' => 'Test', 'second_name_ar' => 'Test', 'third_name_ar' => 'Test', 'last_name_ar' => 'Test',
        'first_name_en' => 'Test', 'second_name_en' => 'Test', 'third_name_en' => 'Test', 'last_name_en' => 'Test',
        'gender' => 'male', 'nationality' => 'SA', 'date_of_birth' => '2000-01-01',
        'national_id_number' => '1000000006', 'email_address' => 'major@test.com', 'mobile_number' => '0500000000',
        'high_school_gpa' => '95.5', 'desired_academic_level' => '1', 'is_verified' => '0'
    ]);
echo "Status: " . $response->status() . " Body: " . $response->body() . "\n";
