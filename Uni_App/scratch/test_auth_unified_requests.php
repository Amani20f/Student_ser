<?php

// Bootstrap Laravel
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

use App\Models\User;
use Illuminate\Support\Facades\Auth;

// 1. Get student_affairs user
$user = User::where('email', 'affairs@university.edu')->first();
if (!$user) {
    echo "ERROR: affairs@university.edu user not found.\n";
    exit(1);
}

// 2. Mock login
Auth::login($user);

// 3. Make request
$request = Illuminate\Http\Request::create('/api/admin/unified-requests', 'GET');
$request->setUserResolver(fn () => $user);

$response = $kernel->handle($request);

echo "STATUS CODE: " . $response->getStatusCode() . "\n";
echo "RESPONSE CONTENT: " . substr($response->getContent(), 0, 500) . "\n";
