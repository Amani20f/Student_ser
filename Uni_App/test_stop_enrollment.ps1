$api = "http://10.0.2.2:8000/api"
$login = Invoke-RestMethod -Method Post -Uri "$api/login" -ContentType "application/json" -Body (@{email='student1@university.edu'; password='password'} | ConvertTo-Json)
$token = $login.token
$semesters = Invoke-RestMethod -Method Get -Uri "$api/semesters" -Headers @{Authorization = "Bearer $token"}
$semesterId = $semesters.data[0].id
$response = Invoke-RestMethod -Method Post -Uri "$api/student/service-requests" -Headers @{Authorization = "Bearer $token"} -Form @{
    request_type_id = '2'
    suspension_reason = 'test reason'
    start_semester_id = $semesterId
    duration_semesters = '1'
    attachment = Get-Item "d:/modify_student_services-main/Uni_App/dummy.txt"
}
$response | ConvertTo-Json
