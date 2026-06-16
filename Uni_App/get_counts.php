<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$stats = \App\Models\Request::select('status', \Illuminate\Support\Facades\DB::raw('count(*) as total'))
    ->groupBy('status')
    ->pluck('total', 'status');
echo "COUNTS_JSON: " . json_encode($stats) . "\n";
