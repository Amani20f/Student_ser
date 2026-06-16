<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Program;

$programs = Program::where('is_available', true)
    ->select('id', 'name', 'certificate_type', 'minimum_percentage', 'is_available')
    ->orderBy('id', 'asc')
    ->get();

printf("| %-2s | %-70s | %-16s | %-18s | %-12s |\n", "id", "name", "certificate_type", "minimum_percentage", "is_available");
printf("|----|------------------------------------------------------------------------|------------------|--------------------|--------------|\n");
foreach ($programs as $p) {
    printf("| %-2d | %-70s | %-16s | %-18s | %-12s |\n", 
        $p->id, 
        $p->name, 
        $p->certificate_type, 
        number_format($p->minimum_percentage, 2) . "%", 
        $p->is_available ? 'true' : 'false'
    );
}
