<?php
$chLogin = curl_init('http://127.0.0.1:8000/api/login');
curl_setopt($chLogin, CURLOPT_RETURNTRANSFER, true);
curl_setopt($chLogin, CURLOPT_POST, true);
curl_setopt($chLogin, CURLOPT_POSTFIELDS, json_encode(['email'=>'student1@university.edu','password'=>'password']));
curl_setopt($chLogin, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Accept: application/json']);
$loginRes = curl_exec($chLogin);
$token = json_decode($loginRes, true)['data']['token'] ?? '';
curl_close($chLogin);

if (!$token) {
    die("Login failed: $loginRes\n");
}

$ch = curl_init('http://127.0.0.1:8000/api/student/service-requests');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
$data = [
    'request_type_id' => '2',
    'suspension_reason' => 'Test reason for suspension',
    'start_semester_id' => '4',
    'duration_semesters' => '1',
    'attachment' => new CURLFile('d:/modify_student_services-main/Uni_App/dummy.pdf')
];
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Authorization: Bearer ' . $token, 'Accept: application/json']);
$res = curl_exec($ch);
$info = curl_getinfo($ch);
curl_close($ch);

echo "Status Code: " . $info['http_code'] . "\n";
echo "Response: " . $res . "\n";
