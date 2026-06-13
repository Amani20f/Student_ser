<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

file_put_contents('fake_photo.jpg', chr(0));

use Illuminate\Http\UploadedFile;
$file = new UploadedFile('fake_photo.jpg', 'fake_photo.jpg', null, null, true);

$request = Illuminate\Http\Request::create('/api/apply', 'POST', [
    'full_name' => 'Test User',
    'national_id_number' => '999999999',
    'date_of_birth' => '2000-01-01',
    'gender' => 'male',
    'nationality' => 'Saudi',
    'phone_number' => '0500000000',
    'email_address' => 'fake_email@test.com',
    'desired_program_id' => 1,
    'desired_academic_level' => 1,
], [], ['personal_photo' => $file]);

$request->headers->set('Accept', 'application/json');

$response = $kernel->handle($request);
echo "Response: " . $response->getContent() . "\n";
unlink('fake_photo.jpg');
