<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

$results = DB::select("
    SELECT conname, pg_get_constraintdef(oid) 
    FROM pg_constraint 
    WHERE conrelid = 'student_applications'::regclass;
");

foreach ($results as $row) {
    echo "Constraint Name: {$row->conname}\n";
    echo "Definition: {$row->pg_get_constraintdef}\n\n";
}
