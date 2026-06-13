<?php
require __DIR__."/vendor/autoload.php";
$app = require_once __DIR__."/bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// 1. Semester Loading
echo "\n--- 1. Semester Loading ---\n";
$semestersResponse = app(\App\Http\Controllers\Api\AcademicStructureController::class)->semesters()->getData();
echo json_encode($semestersResponse, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n";

// 2. Template Download
echo "\n--- 2. Template Download ---\n";
$controller = app(\App\Http\Controllers\Api\Staff\GradeImportController::class);
$response = $controller->template();
ob_start();
$response->sendContent();
$csv = ob_get_clean();
echo $csv . "\n";
