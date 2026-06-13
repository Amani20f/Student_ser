<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$request = Illuminate\Http\Request::create('/api/apply', 'POST', [
    'full_name' => 'John Doe (John)',
    'national_id_number' => '1234567890',
    'date_of_birth' => '2000-01-01',
    'gender' => 'male',
    'nationality' => 'Saudi',
    'phone_number' => '0501234567',
    'email_address' => 'johndoe@example.com',
    'address' => 'Riyadh',
    'desired_program_id' => '1',
    'desired_academic_level' => '1',
    'form_responses' => '{}'
]);

$response = $kernel->handle($request);

echo "Status: " . $response->status() . "\n";
echo "Content: " . $response->getContent() . "\n";
