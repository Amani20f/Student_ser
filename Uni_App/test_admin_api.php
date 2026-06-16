<?php

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = \App\Models\User::where('role', 'admin')->first();

if (!$user) {
    echo "No admin user found.\n";
    exit;
}

\Laravel\Sanctum\Sanctum::actingAs($user);

$request = \Illuminate\Http\Request::create('/api/admin/applications', 'GET');
$request->headers->set('Accept', 'application/json');

$kernelHttp = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernelHttp->handle($request);

echo "Status Code: " . $response->getStatusCode() . "\n";
echo "Content: \n";
echo json_encode(json_decode($response->getContent()), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
