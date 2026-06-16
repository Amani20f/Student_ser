<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Program;
use App\Models\College;

$programs = Program::with('department.college')->get();
foreach ($programs as $p) {
    echo "ID: {$p->id} | Name: {$p->name} | Code: {$p->code} | College: " . ($p->department?->college?->name ?? 'None') . " | Available: " . ($p->is_available ? 'YES' : 'NO') . " | Certificate: {$p->certificate_type} | Min %: {$p->minimum_percentage}\n";
}
