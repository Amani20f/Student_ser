<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\StudentApplication;

$a = StudentApplication::find(19);
if ($a) {
    echo "=== Student Application ID 19 ===\n";
    foreach ($a->toArray() as $key => $val) {
        echo "$key: " . (is_array($val) ? json_encode($val) : $val) . "\n";
    }
} else {
    echo "Student Application ID 19 not found!\n";
}
