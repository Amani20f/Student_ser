<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\StudentApplication;
use Laravel\Sanctum\Sanctum;

// Bind request to container
$initialRequest = Illuminate\Http\Request::create('/', 'GET');
$app->instance('request', $initialRequest);

// Reset Application 19 to pending for clean run
$app19 = StudentApplication::find(19);
$app19->application_status = 'pending';
$app19->save();

echo "Application 19 status reset to: " . $app19->application_status . "\n";

// 1. Authenticate as Accountant
$accountant = User::where('email', 'accountant@university.edu')->first();
Sanctum::actingAs($accountant, ['*']);

echo "Logged in as Accountant: " . $accountant->email . "\n";

// Get Payments list via controller
$request = Illuminate\Http\Request::create('/api/staff/payments', 'GET', ['status' => 'pending']);
$app->instance('request', $request);
$response = app()->handle($request);
$data = json_decode($response->getContent(), true);

$foundInPayments = false;
if (isset($data['data'])) {
    foreach ($data['data'] as $payment) {
        if ($payment['id'] === -19) {
            $foundInPayments = true;
            echo "✓ Application 19 (mapped as -19) is visible in Accountant Payments list with status: " . $payment['status'] . "\n";
            break;
        }
    }
}
if (!$foundInPayments) {
    echo "✗ Application 19 is NOT visible in Accountant Payments list.\n";
}

// Get Unified Requests list for Accountant
$requestUr = Illuminate\Http\Request::create('/api/admin/unified-requests', 'GET');
$app->instance('request', $requestUr);
$responseUr = app()->handle($requestUr);
$dataUr = json_decode($responseUr->getContent(), true);

$foundInUrAccountant = false;
if (isset($dataUr['data'])) {
    foreach ($dataUr['data'] as $item) {
        if ($item['original_type'] === 'student_application' && $item['id'] === 19) {
            $foundInUrAccountant = true;
            break;
        }
    }
}
if (!$foundInUrAccountant) {
    echo "✓ Application 19 is NOT visible in Accountant Unified Requests list (as required).\n";
} else {
    echo "✗ Application 19 is visible in Accountant Unified Requests list!\n";
}

// 2. Authenticate as Student Affairs
$affairs = User::where('email', 'affairs@university.edu')->first();
Sanctum::actingAs($affairs, ['*']);
echo "Logged in as Student Affairs: " . $affairs->email . "\n";

// Get Unified Requests list for Student Affairs
$requestUrSa = Illuminate\Http\Request::create('/api/admin/unified-requests', 'GET');
$app->instance('request', $requestUrSa);
$responseUrSa = app()->handle($requestUrSa);
$dataUrSa = json_decode($responseUrSa->getContent(), true);

$foundInUrSaPending = false;
if (isset($dataUrSa['data'])) {
    foreach ($dataUrSa['data'] as $item) {
        if ($item['original_type'] === 'student_application' && $item['id'] === 19) {
            $foundInUrSaPending = true;
            break;
        }
    }
}
if (!$foundInUrSaPending) {
    echo "✓ Application 19 is NOT visible in Student Affairs Unified Requests list while pending.\n";
} else {
    echo "✗ Application 19 is visible in Student Affairs Unified Requests list while pending!\n";
}

// 3. Verify Payment as Accountant
Sanctum::actingAs($accountant, ['*']);
$verifyRequest = Illuminate\Http\Request::create('/api/staff/payments/-19/verify', 'PUT');
$app->instance('request', $verifyRequest);
$verifyResponse = app()->handle($verifyRequest);
echo "Verify response: " . $verifyResponse->getContent() . "\n";

// Check new status of Application 19
$app19->refresh();
echo "Application 19 status after Accountant verification: " . $app19->application_status . "\n";

// Get Payments list again
$request2 = Illuminate\Http\Request::create('/api/staff/payments', 'GET', ['status' => 'pending']);
$app->instance('request', $request2);
$response2 = app()->handle($request2);
$data2 = json_decode($response2->getContent(), true);

$foundInPaymentsAfter = false;
if (isset($data2['data'])) {
    foreach ($data2['data'] as $payment) {
        if ($payment['id'] === -19) {
            $foundInPaymentsAfter = true;
            break;
        }
    }
}
if (!$foundInPaymentsAfter) {
    echo "✓ Application 19 is no longer visible in Accountant Payments list (disappeared).\n";
} else {
    echo "✗ Application 19 is still visible in Accountant Payments list!\n";
}

// 4. Authenticate as Student Affairs and check Unified Requests
Sanctum::actingAs($affairs, ['*']);
$requestUrSaAfter = Illuminate\Http\Request::create('/api/admin/unified-requests', 'GET');
$app->instance('request', $requestUrSaAfter);
$responseUrSaAfter = app()->handle($requestUrSaAfter);
$dataUrSaAfter = json_decode($responseUrSaAfter->getContent(), true);

$foundInUrSaAfter = false;
if (isset($dataUrSaAfter['data'])) {
    foreach ($dataUrSaAfter['data'] as $item) {
        if ($item['original_type'] === 'student_application' && $item['id'] === 19) {
            $foundInUrSaAfter = true;
            echo "✓ Application 19 is now visible in Student Affairs Unified Requests list (with status: " . $item['status'] . ").\n";
            break;
        }
    }
}
if (!$foundInUrSaAfter) {
    echo "✗ Application 19 is NOT visible in Student Affairs Unified Requests list after payment verification!\n";
}
