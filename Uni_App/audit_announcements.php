<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "========== ANNOUNCEMENT ROUTES ==========\n";
foreach(Route::getRoutes() as $r){ 
    if(str_contains($r->uri, 'announcement')){ 
        echo $r->uri . ' => ' . $r->getActionName() . ' [' . implode(', ', $r->middleware()) . '] ' . "\n"; 
    } 
}

echo "\n========== SIMULATE API CALL ==========\n";
// Find admin user
$adminUser = \App\Models\User::where('role', 'admin')->first();
if (!$adminUser) {
    echo "No admin user found.\n";
    exit;
}
echo "Admin User: {$adminUser->name} (ID: {$adminUser->id})\n";

$token = $adminUser->createToken('audit')->plainTextToken;

$data = [
    'title' => 'Test Announcement ' . time(),
    'content' => 'This is a test announcement content.',
    'target_audience' => 'all',
    'is_important' => 1,
    'is_active' => 1,
];

// Instead of curl, let's use Laravel's internal testing approach or just simple Http client if available, but curl is fine.
$ch = curl_init("http://127.0.0.1:8000/api/staff/announcements");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer {$token}",
    "Accept: application/json",
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: {$httpCode}\n";
echo "Response: {$response}\n";

echo "\n========== CHECK DATABASE ==========\n";
$latest = \App\Models\Announcement::orderBy('id', 'desc')->first();
if ($latest) {
    echo "Latest announcement: ID: {$latest->id}, Title: {$latest->title}, Created At: {$latest->created_at}\n";
    echo "Image path: " . ($latest->image_path ? $latest->image_path : 'NULL') . "\n";
} else {
    echo "No announcements in database.\n";
}
