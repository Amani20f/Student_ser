<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\StudentApplication;

$application = StudentApplication::find(19);
if ($application) {
    $application->update(['application_status' => 'pending']);
    echo "Successfully reset student application 19 to pending.\n";
} else {
    echo "Application 19 not found.\n";
}
