@echo off
REM ========================================
REM Run ALL Tests
REM ========================================

echo.
echo ========================================
echo   Running ALL Tests
echo ========================================
echo.

if not exist "vendor\bin\sail" (
    echo [ERROR] Laravel Sail not found!
    pause
    exit /b 1
)

echo [INFO] Running complete test suite...
echo.

vendor\bin\sail test

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   All Tests PASSED! ✓
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   Some Tests FAILED! ✗
    echo ========================================
)

echo.
pause
