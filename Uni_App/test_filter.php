<?php
require __DIR__."/vendor/autoload.php";
$app = require_once __DIR__."/bootstrap/app.php";
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$request = new \Illuminate\Http\Request(['semester_id' => 2]);
$grades = \App\Models\Grade::with(['student.user', 'course', 'semester'])->filter(new \App\Filters\GradeFilter($request))->get();
$resources = \App\Http\Resources\GradeResource::collection($grades)->resolve();

echo json_encode($resources, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
