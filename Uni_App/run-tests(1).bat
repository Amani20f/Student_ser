@echo off
REM ========================================
REM Service Request Test Runner
REM ========================================

echo.
echo ========================================
echo   Service Request Test Suite
echo ========================================
echo.

REM Check if vendor directory exists
if not exist "vendor" (
    echo [ERROR] Vendor directory not found!
    echo Please run: composer install
    echo.
    pause
    exit /b 1
)

REM Check if Sail exists
if not exist "vendor\bin\sail" (
    echo [ERROR] Laravel Sail not found!
    echo Please ensure Laravel Sail is installed.
    echo.
    pause
    exit /b 1
)

echo [INFO] Running Service Request Tests...
echo.

REM Run the tests
vendor\bin\sail test --filter=ServiceRequestTest

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   Tests PASSED! ✓
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo   Tests FAILED! ✗
    echo ========================================
    echo.
    echo Check the output above for errors.
    echo.
)

pause
