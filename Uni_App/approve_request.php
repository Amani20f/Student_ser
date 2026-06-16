<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$req = \App\Models\Request::find(28);
$req->accept('Approved from script for E2E Test');

echo "Student Status is now: " . $req->student->status->value . "\n";
