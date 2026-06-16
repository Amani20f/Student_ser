<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// Find admin user
$adminUser = \App\Models\User::where('role', 'admin')->first();
$token = $adminUser->createToken('audit')->plainTextToken;

// Simulate exactly what Dart sends:
// 'title': 'Test title'
// 'content': 'Test content'
// 'target_audience': 'all_students'
// 'is_active': 'true'
// 'send_notification': 'false'

$postFields = [
    'title' => 'Test title ' . time(),
    'content' => 'Test content',
    'target_audience' => 'all_students',
    'is_active' => 'true',
    'send_notification' => 'false',
];

$ch = curl_init("http://127.0.0.1:8000/api/staff/announcements");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer {$token}",
    "Accept: application/json",
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "========== EXACT API ENDPOINT ==========\n";
echo "POST /api/staff/announcements\n\n";

echo "========== FULL REQUEST PAYLOAD ==========\n";
print_r($postFields);
echo "\n";

echo "========== HTTP STATUS CODE ==========\n";
echo $httpCode . "\n\n";

echo "========== JSON ERROR RESPONSE ==========\n";
echo $response . "\n\n";

echo "========== CHECK DATABASE FOR NEW RECORD ==========\n";
$latest = \App\Models\Announcement::orderBy('id', 'desc')->first();
if ($latest && str_contains($latest->title, 'Test title')) {
    echo "Record CREATED successfully. ID: {$latest->id}\n";
} else {
    echo "Record NOT created.\n";
}
