<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\StudentApplication;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\Admin\UnifiedRequestController;
use App\Http\Controllers\Api\Admin\StudentApplicationManagementController;

// Reset Application 19 to pending for clean testing
$application = StudentApplication::find(19);
if ($application) {
    $application->update(['application_status' => 'pending']);
    echo "Reset student application 19 to pending.\n";
}

// 1. Authenticate as Accountant (User ID 3)
$accountant = User::find(3); // أحمد المحاسب
auth()->login($accountant);
echo "Logged in as Accountant: {$accountant->name}\n";

// Test Unified Requests for Accountant
$controller = new UnifiedRequestController();
$req = Request::create('/admin/unified-requests', 'GET');
$response = $controller->index($req);
$data = json_decode($response->getContent(), true);

$appInAccountant = null;
foreach ($data['data'] as $item) {
    if ($item['original_type'] === 'student_application' && $item['id'] == 19) {
        $appInAccountant = $item;
        break;
    }
}

if ($appInAccountant) {
    echo "✓ Success: Accountant sees student application 19 (Status: {$appInAccountant['status']})\n";
} else {
    echo "✗ Fail: Accountant DOES NOT see student application 19!\n";
}

// 2. Perform Verify Payment as Accountant
$appController = new StudentApplicationManagementController();
$verifyReq = Request::create("/staff/applications/19/verify-payment", "PUT");
$verifyResponse = $appController->verifyPayment($verifyReq, 19);
echo "Verify Payment Response: " . $verifyResponse->getContent() . "\n";

// Check status in DB
$application->refresh();
echo "Status in DB after verify: {$application->application_status}\n";

// 3. Authenticate as Student Affairs (User ID 2)
$affairs = User::find(2); // سارة الشؤون
auth()->login($affairs);
echo "Logged in as Student Affairs: {$affairs->name}\n";

// Test Unified Requests for Student Affairs
$response = $controller->index($req);
$data = json_decode($response->getContent(), true);

$appInAffairs = null;
foreach ($data['data'] as $item) {
    if ($item['original_type'] === 'student_application' && $item['id'] == 19) {
        $appInAffairs = $item;
        break;
    }
}

if ($appInAffairs) {
    echo "✓ Success: Student Affairs sees student application 19 (Status: {$appInAffairs['status']})\n";
} else {
    echo "✗ Fail: Student Affairs DOES NOT see student application 19!\n";
}
