@echo off
chcp 65001 >nul
echo ========================================
echo 全平台心理自助应用系统 - 快速启动脚本
echo ========================================
echo.

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Docker，请先安装Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [✓] Docker已安装
echo.

REM 检查.env文件是否存在
if not exist .env (
    echo [!] 未找到.env文件，正在复制.env.example...
    copy .env.example .env
    echo.
    echo [警告] 请编辑.env文件，设置以下内容:
    echo   1. POSTGRES_PASSWORD - 数据库密码
    echo   2. JWT_SECRET - JWT密钥（至少32字符）
    echo.
    echo 按任意键继续（确认已配置）或Ctrl+C取消...
    pause >nul
)

echo [1/4] 停止现有容器...
docker-compose down >nul 2>&1

echo [2/4] 启动数据库和Redis...
docker-compose up -d postgres redis
echo 等待数据库初始化（30秒）...
timeout /t 30 /nobreak >nul

echo [3/4] 启动后端服务...
docker-compose up -d backend

echo [4/4] 检查服务状态...
timeout /t 5 /nobreak >nul
docker-compose ps

echo.
echo ========================================
echo 部署完成！正在测试健康检查...
echo ========================================
timeout /t 3 /nobreak >nul

curl -s http://localhost:3000/health
if errorlevel 1 (
    echo.
    echo [!] 健康检查失败，查看日志:
    docker-compose logs backend
) else (
    echo.
    echo.
    echo [✓] 系统启动成功！
    echo.
    echo 访问地址:
    echo   - 后端API: http://localhost:3000
    echo   - 健康检查: http://localhost:3000/health
    echo   - 数据库: localhost:5432
    echo   - Redis: localhost:6379
    echo.
    echo 查看日志: docker-compose logs -f backend
    echo 停止服务: docker-compose down
    echo.
)

pause
@echo off
chcp 65001 >nul
echo ========================================
echo 全平台心理自助应用系统 - 快速启动脚本
echo ========================================
echo.

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Docker，请先安装Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [✓] Docker已安装
echo.

REM 检查.env文件是否存在
if not exist .env (
    echo [!] 未找到.env文件，正在复制.env.example...
    copy .env.example .env
    echo.
    echo [警告] 请编辑.env文件，设置以下内容:
    echo   1. POSTGRES_PASSWORD - 数据库密码
    echo   2. JWT_SECRET - JWT密钥（至少32字符）
    echo.
    echo 按任意键继续（确认已配置）或Ctrl+C取消...
    pause >nul
)

echo [1/4] 停止现有容器...
docker-compose down >nul 2>&1

echo [2/4] 启动数据库和Redis...
docker-compose up -d postgres redis
echo 等待数据库初始化（30秒）...
timeout /t 30 /nobreak >nul

echo [3/4] 启动后端服务...
docker-compose up -d backend

echo [4/4] 检查服务状态...
timeout /t 5 /nobreak >nul
docker-compose ps

echo.
echo ========================================
echo 部署完成！正在测试健康检查...
echo ========================================
timeout /t 3 /nobreak >nul

curl -s http://localhost:3000/health
if errorlevel 1 (
    echo.
    echo [!] 健康检查失败，查看日志:
    docker-compose logs backend
) else (
    echo.
    echo.
    echo [✓] 系统启动成功！
    echo.
    echo 访问地址:
    echo   - 后端API: http://localhost:3000
    echo   - 健康检查: http://localhost:3000/health
    echo   - 数据库: localhost:5432
    echo   - Redis: localhost:6379
    echo.
    echo 查看日志: docker-compose logs -f backend
    echo 停止服务: docker-compose down
    echo.
)

pause
