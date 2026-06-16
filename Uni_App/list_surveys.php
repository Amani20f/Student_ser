<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

foreach(\App\Models\Survey::all() as $s) {
    echo "ID: $s->id | Title: $s->title | Required: $s->is_required_for_grades | Level: $s->target_level | Prog: $s->target_program_id | Coll: $s->target_college_id\n";
}
