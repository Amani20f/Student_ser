<?php

function post($url, $data) {
    $options = [
        'http' => [
            'header'  => "Content-Type: application/json\r\n",
            'method'  => 'POST',
            'content' => json_encode($data),
            'ignore_errors' => true,
        ],
    ];
    $context  = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    return [
        'body' => $result,
        'headers' => $http_response_header ?? []
    ];
}

function get($url, $token) {
    $options = [
        'http' => [
            'header'  => "Content-Type: application/json\r\n" .
                         "Authorization: Bearer $token\r\n",
            'method'  => 'GET',
            'ignore_errors' => true,
        ],
    ];
    $context  = stream_context_create($options);
    $result = file_get_contents($url, false, $context);
    return [
        'body' => $result,
        'headers' => $http_response_header ?? []
    ];
}

// 1. Login
echo "Attempting to login affairs@university.edu...\n";
$loginRes = post('http://127.0.0.1:8000/api/login', [
    'email' => 'affairs@university.edu',
    'password' => 'password'
]);

$loginData = json_decode($loginRes['body'], true);
if (empty($loginData['data']['token'])) {
    echo "Login failed! Response:\n";
    print_r($loginRes['body']);
    exit(1);
}

$token = $loginData['data']['token'];
echo "Login success. Token obtained.\n";

// 2. Access unified-requests
echo "Requesting GET /api/admin/unified-requests...\n";
$reqRes = get('http://127.0.0.1:8000/api/admin/unified-requests', $token);

echo "Response headers:\n";
print_r($reqRes['headers'][0] ?? 'No headers');
echo "\nResponse body (first 1000 chars):\n";
echo substr($reqRes['body'], 0, 1000) . "\n";
