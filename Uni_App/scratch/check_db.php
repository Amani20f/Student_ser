<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== COLLEGES ===\n";
$colleges = DB::table('colleges')->orderBy('id')->get(['id','code','name']);
foreach ($colleges as $c) {
    echo "ID:{$c->id} | Code:{$c->code} | Name:{$c->name}\n";
}

echo "\n=== DEPARTMENTS ===\n";
$depts = DB::table('departments')->orderBy('id')->get(['id','code','name','college_id']);
foreach ($depts as $d) {
    echo "ID:{$d->id} | Code:{$d->code} | Name:{$d->name} | College:{$d->college_id}\n";
}

echo "\n=== PROGRAMS (" . DB::table('programs')->count() . " total) ===\n";
$progs = DB::table('programs')->orderBy('id')->get(['id','code','name','department_id','degree_type']);
foreach ($progs as $p) {
    echo "ID:{$p->id} | Code:{$p->code} | Dept:{$p->department_id} | Name:{$p->name}\n";
}
