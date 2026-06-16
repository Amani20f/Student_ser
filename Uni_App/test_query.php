<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$q = App\Models\Survey::where('is_active', true)
    ->where('is_required_for_grades', true)
    ->where(function($query) {
        $query->where(function ($sub) {
            $sub->whereNull('target_college_id')->orWhere('target_college_id', 1);
        })
        ->where(function ($sub) {
            $sub->whereNull('target_program_id')->orWhere('target_program_id', 1);
        })
        ->where(function ($sub) {
            $sub->whereNull('target_level')->orWhere('target_level', 2);
        });
    });

echo "SQL: " . $q->toSql() . "\n";
echo "Bindings: " . json_encode($q->getBindings()) . "\n";
echo "Results IDs: " . json_encode($q->get()->pluck('id')->toArray()) . "\n";
