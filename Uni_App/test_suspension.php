<?php
$student = \App\Models\Student::first();
$student->status = \App\Enums\StudentStatusEnum::ACTIVE;
$student->save();

$requestType = \App\Models\RequestType::where('slug', 'suspension_of_enrollment')->first();
$req = \App\Models\Request::create([
    'student_id' => $student->id,
    'request_type_id' => $requestType->id,
    'description' => 'Test Suspension',
    'semester_id' => 1,
    'form_data' => ['semester' => 1, 'reason' => 'test'],
    'status' => \App\Enums\RequestStatusEnum::PENDING
]);

echo "--- SUSPENSION TEST ---\n";
echo "Before approval: " . $student->fresh()->status->value . "\n";

$req->status = \App\Enums\RequestStatusEnum::APPROVED;
$req->save();

echo "After approval: " . $student->fresh()->status->value . "\n";

echo "--- RE-ENROLLMENT TEST ---\n";
$requestType2 = \App\Models\RequestType::where('slug', 're_enrollment')->first();
$req2 = \App\Models\Request::create([
    'student_id' => $student->id,
    'request_type_id' => $requestType2->id,
    'description' => 'Test Re-enrollment',
    'semester_id' => 1,
    'form_data' => ['semester' => 1, 'reason' => 'test'],
    'status' => \App\Enums\RequestStatusEnum::PENDING
]);

echo "Before approval: " . $student->fresh()->status->value . "\n";
$req2->status = \App\Enums\RequestStatusEnum::APPROVED;
$req2->save();
echo "After approval: " . $student->fresh()->status->value . "\n";
