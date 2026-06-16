<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

$columns = DB::select("
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_name = 'student_applications'
      AND column_name IN ('first_choice_program_id', 'second_choice_program_id', 'third_choice_program_id', 'approved_program_id')
    ORDER BY column_name ASC
");

printf("%-30s | %-15s | %-12s\n", "Column Name", "Data Type", "Is Nullable");
echo str_repeat("-", 65) . "\n";
foreach ($columns as $col) {
    printf("%-30s | %-15s | %-12s\n", $col->column_name, $col->data_type, $col->is_nullable);
}
