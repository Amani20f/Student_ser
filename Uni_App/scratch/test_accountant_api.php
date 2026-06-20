<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\Admin\UnifiedRequestController;

$accountant = User::where('email', 'accountant@university.edu')->first();
if (!$accountant) {
    echo "Accountant user not found!\n";
    exit(1);
}

auth()->login($accountant);
echo "Logged in as {$accountant->name} (Role: {$accountant->role})\n";
echo "Roles from Spatie: " . json_encode($accountant->getRoleNames()) . "\n";

$req = Request::create('/api/admin/unified-requests', 'GET');
$controller = new UnifiedRequestController();
try {
    $response = $controller->index($req);
    echo "Response status: " . $response->getStatusCode() . "\n";
    echo "Response JSON:\n" . json_encode(json_decode($response->getContent(), true), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
