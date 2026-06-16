<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\College;

$colleges = College::with('departments')->get();
foreach ($colleges as $c) {
    echo "College ID: {$c->id} | Name: {$c->name} | Code: {$c->code}\n";
    foreach ($c->departments as $d) {
        echo "  Dept ID: {$d->id} | Name: {$d->name} | Code: {$d->code}\n";
    }
}
