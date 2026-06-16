<?php

// Bootstrap Laravel
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::create('/api/admin/unified-requests', 'GET')
);

// We need to bypass authentication for local script check, so let's call the controller action directly:
use App\Http\Controllers\Api\Admin\UnifiedRequestController;
use Illuminate\Http\Request as LaravelRequest;

// Mock login as admin or just invoke the method
$controller = new UnifiedRequestController();
$laravelRequest = LaravelRequest::create('/api/admin/unified-requests', 'GET');

// Run
try {
    $res = $controller->index($laravelRequest);
    $data = json_decode($res->getContent(), true);
    
    echo "SUCCESS: Unified requests returned " . count($data['data']) . " items.\n";
    if (count($data['data']) > 0) {
        echo "Sample item:\n";
        print_r(array_intersect_key($data['data'][0], array_flip(['id', 'original_type', 'request_type', 'student_name', 'submitted_date', 'status'])));
    }
} catch (\Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
