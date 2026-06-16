<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$programs = \App\Models\Program::select('id', 'name', 'certificate_type', 'minimum_percentage', 'is_available')
    ->orderBy('id', 'asc')
    ->get();

printf("%-3s | %-40s | %-16s | %-18s | %-12s\n", "id", "name", "certificate_type", "minimum_percentage", "is_available");
echo str_repeat("-", 100) . "\n";
foreach ($programs as $p) {
    printf("%-3d | %-40s | %-16s | %-18.2f | %-12d\n", $p->id, $p->name, $p->certificate_type, $p->minimum_percentage, $p->is_available);
}
