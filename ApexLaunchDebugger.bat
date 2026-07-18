@echo off
echo ====================================================
echo  Apex Legends Launch Debugger
echo ====================================================

:: Check Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This tool must be run with Administrator privileges.
    echo         Please right-click "ApexLaunchDebugger.bat" and select "Run as Administrator".
    echo.
    pause
    exit /b
)

:: Change directory to script folder
cd /d "%~dp0"

:: Check if script exists
set SCRIPT_NAME=ApexLaunchDebugger.ps1
if not exist "%SCRIPT_NAME%" (
    echo [ERROR] "%SCRIPT_NAME%" not found.
    echo         Please extract (unzip) the folder before running.
    echo.
    pause
    exit /b
)

echo Running PowerShell script. Please wait...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0%SCRIPT_NAME%"

if %errorlevel% neq 0 (
    echo [ERROR] An error occurred while executing PowerShell.
    echo         Make sure Windows Defender or antivirus is not blocking it.
)

echo.
echo Complete. Press any key to exit.
pause >nul
