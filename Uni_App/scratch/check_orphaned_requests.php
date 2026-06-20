<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Request as StudentRequest;
use App\Models\Student;

$orphans = StudentRequest::whereNotExists(function ($query) {
    $query->select(\Illuminate\Support\Facades\DB::raw(1))
          ->from('students')
          ->whereColumn('students.id', 'requests.student_id');
})->get();

echo "Found " . $orphans->count() . " orphaned requests:\n";
foreach ($orphans as $o) {
    echo "- Request ID: {$o->id}, Student ID: {$o->student_id}\n";
}
