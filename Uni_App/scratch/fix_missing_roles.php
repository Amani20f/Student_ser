<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();

use App\Models\User;

$users = User::where('role', 'student')->get();
foreach ($users as $user) {
    if (!$user->hasRole('student')) {
        $user->assignRole('student');
        echo "✓ Assigned 'student' role to: " . $user->email . "\n";
    }
}
echo "Done fixing roles.\n";
