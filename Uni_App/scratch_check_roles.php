<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$users = App\Models\User::all();
foreach ($users as $u) {
    echo "ID: " . $u->id . " | Username: " . $u->username . " | Roles: " . implode(', ', $u->getRoleNames()->toArray()) . "\n";
}
