$api = "http://127.0.0.1:8000/api"

# Login and obtain token
$loginResponse = Invoke-RestMethod -Method Post -Uri "$api/login" -Headers @{Accept='application/json'} -ContentType "application/json" -Body (@{email='student1@university.edu'; password='password'} | ConvertTo-Json)

# Extract token from response (nested under data)
$token = $loginResponse.data.token

Write-Host "Token: $token"

# Prepare multipart form data for stop enrollment request
$multipart = @{
    request_type_id = '2';
    suspension_reason = 'Test reason for stop enrollment';
    start_semester_id = '1';
    duration_semesters = '1';
    attachment = Get-Item "d:/modify_student_services-main/Uni_App/dummy.txt"
}

# Send request with Authorization header
$response = Invoke-RestMethod -Method Post -Uri "$api/student/service-requests" -Headers @{Authorization = "Bearer $token"} -Form $multipart

Write-Host "Response JSON:"
Write-Output $response | ConvertTo-Json -Depth 5
