@echo off
REM ========================================
REM Docker & Sail Helper
REM ========================================

echo.
echo ========================================
echo   Docker & Sail Helper
echo ========================================
echo.

:menu
echo Choose an option:
echo.
echo 1. Start Sail (Docker containers)
echo 2. Stop Sail (Docker containers)
echo 3. Run Service Request Tests
echo 4. Run ALL Tests
echo 5. Check Docker Status
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto start_sail
if "%choice%"=="2" goto stop_sail
if "%choice%"=="3" goto run_service_tests
if "%choice%"=="4" goto run_all_tests
if "%choice%"=="5" goto check_docker
if "%choice%"=="6" goto exit
goto menu

:start_sail
echo.
echo [INFO] Starting Laravel Sail...
vendor\bin\sail up -d
echo.
echo [SUCCESS] Sail containers started!
echo.
pause
goto menu

:stop_sail
echo.
echo [INFO] Stopping Laravel Sail...
vendor\bin\sail down
echo.
echo [SUCCESS] Sail containers stopped!
echo.
pause
goto menu

:run_service_tests
echo.
echo [INFO] Running Service Request Tests...
echo.
vendor\bin\sail test --filter=ServiceRequestTest
echo.
pause
goto menu

:run_all_tests
echo.
echo [INFO] Running ALL Tests...
echo.
vendor\bin\sail test
echo.
pause
goto menu

:check_docker
echo.
echo [INFO] Checking Docker status...
echo.
docker ps
echo.
pause
goto menu

:exit
echo.
echo Goodbye!
exit /b 0
