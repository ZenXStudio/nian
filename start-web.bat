@echo off
echo ========================================
echo   Nian - Web Development Environment
echo ========================================
echo.

:: 1. Clean processes
echo [1/5] Cleaning processes...
taskkill /F /IM dart.exe > nul 2>&1
echo      Done

:: 2. Check ports
echo [2/5] Checking ports...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    echo      Killing process on port 8080: %%a
    taskkill /F /PID %%a > nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do (
    echo      Killing process on port 3000: %%a
    taskkill /F /PID %%a > nul 2>&1
)
echo      Done

:: 3. Start backend
echo [3/5] Starting backend...
cd /d %~dp0backend
start "Backend Server" cmd /c "npm run dev"
cd /d %~dp0

echo      Waiting for backend...
timeout /t 5 /nobreak > nul

:: 4. Verify backend
echo [4/5] Verifying backend...
:check_backend
curl -s http://localhost:3000/health > nul 2>&1
if %errorlevel% neq 0 (
    echo      Backend not ready, waiting...
    timeout /t 2 /nobreak > nul
    goto check_backend
)
echo      Backend ready (http://localhost:3000)

:: 5. Start Flutter Web
echo [5/5] Starting Flutter Web...
cd /d %~dp0flutter_app
start "Flutter Web" cmd /c "flutter run -d chrome --web-port=8080"
cd /d %~dp0

echo.
echo ========================================
echo   Started!
echo   - Backend API: http://localhost:3000
echo   - Web App: http://localhost:8080
echo ========================================
echo.
echo Tip: Use stop-web.bat to stop all services
pause
