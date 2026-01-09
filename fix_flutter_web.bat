@echo off
chcp 65001 > nul
echo 🛠️ Flutter Web 一键修复工具
echo ==========================

echo.
echo 1️⃣ 清理Flutter进程...
taskkill /F /IM dart.exe > nul 2>&1
taskkill /F /IM flutter.bat > nul 2>&1
taskkill /F /IM adb.exe > nul 2>&1
echo    ✓ 进程清理完成

echo.
echo 2️⃣ 检查端口占用...
netstat -ano | findstr :8080 | findstr LISTENING > nul
if %ERRORLEVEL% == 0 (
    echo    ⚠ 检测到端口8080被占用，正在清理...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
        taskkill /F /PID %%a > nul 2>&1
        echo    ✓ 已终止占用进程 %%a
    )
) else (
    echo    ✓ 端口8080可用
)

echo.
echo 3️⃣ 验证Flutter环境...
flutter --version > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo    ✓ Flutter环境正常
) else (
    echo    ✗ Flutter环境异常，请检查安装
    pause
    exit /b 1
)

echo.
echo 4️⃣ 进入项目目录...
cd flutter_app
if exist pubspec.yaml (
    echo    ✓ 已进入Flutter项目目录
) else (
    echo    ✗ 未找到Flutter项目
    cd ..
    pause
    exit /b 1
)

echo.
echo 5️⃣ 执行项目清理...
flutter clean > nul 2>&1
echo    ✓ 清理完成

echo.
echo 6️⃣ 获取依赖...
flutter pub get > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo    ✓ 依赖获取成功
) else (
    echo    ✗ 依赖获取失败
    cd ..
    pause
    exit /b 1
)

echo.
echo 7️⃣ 启动Flutter Web应用...
echo    目标端口: 8080
echo    浏览器: Chrome
echo    等待应用启动...

start "" flutter run -d chrome --web-port=8080

timeout /t 15 /nobreak > nul

echo.
echo 8️⃣ 验证应用状态...
netstat -ano | findstr :8080 | findstr LISTENING > nul
if %ERRORLEVEL% == 0 (
    echo.
    echo ✅ Flutter Web应用启动成功!
    echo    访问地址: http://localhost:8080
    echo    调试地址: http://localhost:8080/#/
    echo.
    echo 💡 使用 'q' 键退出应用，'r' 键热重载
) else (
    echo.
    echo ❌ 应用启动失败，请检查错误信息
)

echo.
pause