@echo off
set API=http://127.0.0.1:8000/api

rem Login and get token
for /f "tokens=*" %%a in ('curl -s -X POST %API%/login -H "Content-Type: application/json" -d "{\"email\":\"student1@university.edu\",\"password\":\"password\"}"') do set LOGIN_RESPONSE=%%a

rem Extract token using a simple string manipulation (or keep using PS carefully)
for /f "delims=" %%b in ('powershell -NoProfile -Command "$resp = '%LOGIN_RESPONSE%'; $obj = ConvertFrom-Json $resp; $obj.data.token"') do set TOKEN=%%b

echo Token: %TOKEN%
echo Sending Stop Enrollment Request...

curl -s -X POST %API%/student/service-requests ^
  -H "Authorization: Bearer %TOKEN%" ^
  -F "request_type_id=2" ^
  -F "suspension_reason=Test reason for stop enrollment" ^
  -F "start_semester_id=1" ^
  -F "duration_semesters=1" ^
  -F "attachment=@d:/modify_student_services-main/Uni_App/dummy.txt"

