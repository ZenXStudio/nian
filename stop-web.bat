@echo off
echo ========================================
echo   Nian - Stop Web Development Services
echo ========================================
echo.

echo [1/2] Stopping Flutter/Dart...
taskkill /F /IM dart.exe > nul 2>&1
echo      Done

echo [2/2] Stopping Node.js backend...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
    taskkill /F /PID %%a > nul 2>&1
)
echo      Done

echo.
echo ========================================
echo   All services stopped
echo ========================================
pause
