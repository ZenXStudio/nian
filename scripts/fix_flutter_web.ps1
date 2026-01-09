# Flutter Web 自动故障恢复脚本
# 解决常见的Flutter Web启动问题

Write-Host "🔧 Flutter Web 故障诊断和修复工具" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# 1. 清理所有Flutter相关进程
Write-Host "`n1️⃣ 清理Flutter进程..." -ForegroundColor Yellow
try {
    $processes = @("dart.exe", "flutter.bat", "adb.exe")
    foreach ($proc in $processes) {
        $result = taskkill /F /IM $proc 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ 已终止 $proc 进程" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "   ! 清理进程时遇到问题: $_" -ForegroundColor Red
}

# 2. 检查端口占用
Write-Host "`n2️⃣ 检查端口占用..." -ForegroundColor Yellow
$port = 8080
$netstatResult = netstat -ano | findstr ":$port"
if ($netstatResult -match "LISTENING") {
    Write-Host "   ⚠ 端口 $port 正在被占用:" -ForegroundColor Yellow
    Write-Host "   $netstatResult"
    # 尝试终止占用端口的进程
    $pid = ($netstatResult -split '\s+')[-1]
    if ($pid -and $pid -ne "0") {
        try {
            taskkill /F /PID $pid 2>$null
            Write-Host "   ✓ 已终止占用端口的进程 (PID: $pid)" -ForegroundColor Green
        } catch {
            Write-Host "   ! 无法终止进程 PID: $pid" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ✓ 端口 $port 可用" -ForegroundColor Green
}

# 3. 验证Flutter环境
Write-Host "`n3️⃣ 验证Flutter环境..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Flutter 环境正常" -ForegroundColor Green
        # 显示简要版本信息
        $versionLine = ($flutterVersion | Select-String "Flutter").Line
        Write-Host "   版本: $versionLine" -ForegroundColor Gray
    } else {
        Write-Host "   ✗ Flutter 环境异常，请检查安装" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ 无法检测Flutter环境: $_" -ForegroundColor Red
    exit 1
}

# 4. 进入Flutter项目目录
$projectDir = "flutter_app"
if (Test-Path $projectDir) {
    Set-Location $projectDir
    Write-Host "`n4️⃣ 进入项目目录: $(Get-Location)" -ForegroundColor Yellow
} else {
    Write-Host "`n4️⃣ 项目目录不存在: $projectDir" -ForegroundColor Red
    exit 1
}

# 5. 执行清理和重新构建
Write-Host "`n5️⃣ 执行项目清理..." -ForegroundColor Yellow
try {
    flutter clean > $null
    Write-Host "   ✓ 清理完成" -ForegroundColor Green
    
    Write-Host "`n6️⃣ 获取依赖..." -ForegroundColor Yellow
    flutter pub get > $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ 依赖获取成功" -ForegroundColor Green
    } else {
        Write-Host "   ✗ 依赖获取失败" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ 清理或依赖获取失败: $_" -ForegroundColor Red
    exit 1
}

# 7. 启动Flutter Web应用
Write-Host "`n7️⃣ 启动Flutter Web应用..." -ForegroundColor Yellow
Write-Host "   目标端口: 8080" -ForegroundColor Gray
Write-Host "   浏览器: Chrome" -ForegroundColor Gray

try {
    # 在后台启动Flutter应用
    Start-Process -FilePath "flutter" -ArgumentList "run", "-d", "chrome", "--web-port=8080" -NoNewWindow
    
    # 等待应用启动
    Write-Host "   等待应用启动..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
    
    # 验证端口是否在监听
    $retryCount = 0
    $maxRetries = 12  # 最多等待1分钟
    do {
        $listening = netstat -ano | findstr ":8080.*LISTENING"
        if ($listening) {
            Write-Host "`n✅ Flutter Web应用启动成功!" -ForegroundColor Green
            Write-Host "   访问地址: http://localhost:8080" -ForegroundColor Cyan
            Write-Host "   调试地址: http://localhost:8080/#/" -ForegroundColor Cyan
            break
        }
        Start-Sleep -Seconds 5
        $retryCount++
        Write-Host "   等待中... ($retryCount/$maxRetries)" -ForegroundColor Gray
    } while ($retryCount -lt $maxRetries)
    
    if (-not $listening) {
        Write-Host "`n❌ 应用启动超时，请检查错误日志" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "`n❌ 启动应用时发生错误: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 问题已解决！Flutter Web应用正在运行。" -ForegroundColor Green
Write-Host "💡 使用 'q' 键退出应用，'r' 键热重载" -ForegroundColor Yellow