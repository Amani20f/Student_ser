<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Request as StudentRequest;

$requests = StudentRequest::all();
foreach ($requests as $r) {
    echo "ID: {$r->id}, Type: {$r->requestType?->name}, Attachment: " . json_encode($r->attachment) . "\n";
}
