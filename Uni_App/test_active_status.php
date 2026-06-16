<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Enums\StudentStatusEnum;

$student = Student::find(2);

echo "Student Status: " . ($student->status instanceof StudentStatusEnum ? "Enum({$student->status->value})" : "String({$student->status})") . "\n";
if ($student->status !== \App\Enums\StudentStatusEnum::ACTIVE) {
    echo "Check failed! Not active.\n";
} else {
    echo "Check passed! Active.\n";
}

try {
    $service = app(\App\Services\Request\SuspensionRequestService::class);
    $service->validateActiveStatus($student);
    echo "Validate Active Status Method Passed.\n";
} catch (\Exception $e) {
    echo "Exception: " . $e->getMessage() . "\n";
}
