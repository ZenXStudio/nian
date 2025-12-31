# 全平台心理自助应用系统 - 演示脚本

> 本文档提供详细的操作演示脚本，可用于录制视频教程或 GIF 动画演示。

## 📹 演示概述

| 演示名称 | 时长 | 难度 | 目标用户 |
|----------|------|------|----------|
| 快速部署演示 | 2-3分钟 | 初级 | 首次使用者 |
| API 使用演示 | 3-5分钟 | 中级 | 开发者 |
| 管理后台演示 | 2-3分钟 | 初级 | 管理员 |
| 完整功能演示 | 8-10分钟 | 中级 | 所有用户 |

---

## 🎬 演示一：快速部署演示（2-3分钟）

### 演示目标
展示如何在 3 分钟内完成系统部署并验证运行。

### 准备工作
- 确保 Docker Desktop 已安装并运行
- 打开终端/PowerShell
- 准备好项目目录

### 演示步骤

#### 场景 1：打开项目目录（15秒）

```powershell
# 展示：进入项目目录
cd C:\Users\Allen\Documents\GitHub\nian

# 展示：查看项目结构
dir
```

**旁白**：这是 Nian 心理自助应用系统的项目目录，包含后端、管理后台、数据库脚本等。

#### 场景 2：配置环境变量（30秒）

```powershell
# 展示：复制环境变量模板
copy .env.example .env

# 展示：编辑 .env 文件（用记事本或 VS Code）
notepad .env
```

**旁白**：复制环境变量模板，然后修改两个关键配置：数据库密码和 JWT 密钥。

**屏幕显示**：高亮以下行
```env
POSTGRES_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_at_least_32_characters
```

#### 场景 3：启动服务（30秒）

```powershell
# 展示：一键启动所有服务
docker-compose up -d
```

**旁白**：使用 Docker Compose 一键启动所有服务，包括数据库、Redis 缓存和后端 API。

**屏幕显示**：等待容器启动完成的输出

#### 场景 4：验证部署（30秒）

```powershell
# 展示：检查容器状态
docker-compose ps

# 展示：测试健康检查接口
curl http://localhost:3000/health
```

**预期输出**：
```json
{"status":"ok","timestamp":"2024-12-31T..."}
```

**旁白**：所有服务都在运行中，健康检查通过。系统已成功部署！

#### 场景 5：测试 API（45秒）

```powershell
# 展示：注册新用户
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"demo@example.com\",\"password\":\"demo123456\",\"nickname\":\"演示用户\"}'
```

**预期输出**：
```json
{
  "success": true,
  "data": {
    "user": {"id": 1, "email": "demo@example.com", "nickname": "演示用户"},
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**旁白**：用户注册成功！返回了用户信息和 JWT 认证令牌。

### 演示结束
**旁白**：在不到 3 分钟的时间内，我们完成了系统部署和首次 API 测试。接下来您可以探索更多功能！

---

## 🎬 演示二：API 使用演示（3-5分钟）

### 演示目标
展示核心 API 接口的使用方法，包括认证、方法浏览、个人库管理和练习记录。

### 演示步骤

#### 场景 1：用户认证流程（60秒）

**步骤 1.1：用户登录**

```powershell
# 展示：用户登录
$response = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" `
  -Method Post `
  -Body '{"email":"demo@example.com","password":"demo123456"}' `
  -ContentType "application/json"

# 保存 Token
$token = $response.data.token
Write-Host "Token: $token"
```

**旁白**：登录成功后，我们获得了 JWT Token，后续需要认证的接口都需要携带这个 Token。

**步骤 1.2：获取用户信息**

```powershell
# 展示：使用 Token 获取用户信息
$headers = @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "http://localhost:3000/api/auth/me" -Headers $headers
```

**旁白**：使用 Token 可以获取当前登录用户的详细信息。

#### 场景 2：浏览心理自助方法（60秒）

**步骤 2.1：获取方法列表**

```powershell
# 展示：获取方法列表（公开接口，无需认证）
Invoke-RestMethod -Uri "http://localhost:3000/api/methods?page=1&pageSize=5"
```

**旁白**：系统预置了 5 个心理自助方法，包括正念冥想、深呼吸练习等。

**步骤 2.2：搜索方法**

```powershell
# 展示：按关键词搜索
Invoke-RestMethod -Uri "http://localhost:3000/api/methods?search=冥想"
```

**旁白**：支持按标题和描述搜索方法。

**步骤 2.3：查看方法详情**

```powershell
# 展示：获取方法详情
Invoke-RestMethod -Uri "http://localhost:3000/api/methods/1"
```

**旁白**：可以查看方法的详细信息，包括描述、步骤、时长、难度等。

#### 场景 3：个人方法库管理（60秒）

**步骤 3.1：添加方法到个人库**

```powershell
# 展示：添加方法
$body = '{"method_id":1,"personal_goal":"每天冥想10分钟，改善睡眠"}'
Invoke-RestMethod -Uri "http://localhost:3000/api/user/methods" `
  -Method Post -Headers $headers -Body $body -ContentType "application/json"
```

**旁白**：将方法添加到个人库，并设置个人目标。

**步骤 3.2：查看个人方法列表**

```powershell
# 展示：获取个人方法列表
Invoke-RestMethod -Uri "http://localhost:3000/api/user/methods" -Headers $headers
```

#### 场景 4：记录练习（60秒）

**步骤 4.1：记录一次练习**

```powershell
# 展示：记录练习
$practiceBody = @{
    method_id = 1
    duration_minutes = 15
    mood_before = 3
    mood_after = 4
    notes = "感觉很放松，心情平静了很多"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/user/practice" `
  -Method Post -Headers $headers -Body $practiceBody -ContentType "application/json"
```

**旁白**：记录练习时间、练习前后的心情评分，以及个人笔记。

**步骤 4.2：查看练习统计**

```powershell
# 展示：获取练习统计
Invoke-RestMethod -Uri "http://localhost:3000/api/user/practice/statistics" -Headers $headers
```

**旁白**：统计数据包括总练习次数、总时长、心情改善趋势等。

### 演示结束
**旁白**：以上就是核心 API 的使用演示，涵盖了用户认证、方法浏览、个人库管理和练习记录四大模块。

---

## 🎬 演示三：管理后台演示（2-3分钟）

### 演示目标
展示管理后台的主要功能，包括登录、方法管理、内容审核和数据统计。

### 演示步骤

#### 场景 1：管理员登录（30秒）

```powershell
# 展示：管理员登录
$adminResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/login" `
  -Method Post `
  -Body '{"username":"admin","password":"admin123456"}' `
  -ContentType "application/json"

$adminToken = $adminResponse.data.token
$adminHeaders = @{ Authorization = "Bearer $adminToken" }
```

**旁白**：使用管理员账号登录，获取管理员权限的 Token。

#### 场景 2：方法管理（60秒）

**步骤 2.1：查看所有方法（包括草稿）**

```powershell
# 展示：获取所有方法
Invoke-RestMethod -Uri "http://localhost:3000/api/admin/methods" -Headers $adminHeaders
```

**旁白**：管理员可以查看所有状态的方法，包括草稿和待审核的内容。

**步骤 2.2：创建新方法**

```powershell
# 展示：创建方法
$newMethod = @{
    title = "渐进式肌肉放松"
    category = "放松练习"
    description = "通过依次紧绷和放松身体各部位肌肉，达到深度放松的效果"
    difficulty = "beginner"
    duration_minutes = 20
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/admin/methods" `
  -Method Post -Headers $adminHeaders -Body $newMethod -ContentType "application/json"
```

**旁白**：创建新的心理自助方法，初始状态为草稿。

#### 场景 3：内容审核（45秒）

**步骤 3.1：提交审核**

```powershell
# 展示：提交审核
Invoke-RestMethod -Uri "http://localhost:3000/api/admin/methods/6/submit" `
  -Method Post -Headers $adminHeaders
```

**步骤 3.2：审核通过**

```powershell
# 展示：审核通过（需要超级管理员权限）
$approveBody = '{"reviewer_notes":"内容审核通过，可以发布"}'
Invoke-RestMethod -Uri "http://localhost:3000/api/admin/methods/6/approve" `
  -Method Post -Headers $adminHeaders -Body $approveBody -ContentType "application/json"
```

**旁白**：方法经过审核流程后才能发布给用户使用，确保内容质量。

#### 场景 4：数据统计（30秒）

```powershell
# 展示：用户统计
Invoke-RestMethod -Uri "http://localhost:3000/api/admin/statistics/users" -Headers $adminHeaders

# 展示：方法统计
Invoke-RestMethod -Uri "http://localhost:3000/api/admin/statistics/methods" -Headers $adminHeaders
```

**旁白**：管理后台提供用户增长、方法使用等关键数据统计。

### 演示结束
**旁白**：管理后台帮助运营人员管理内容、审核方法、监控数据，确保平台健康运营。

---

## 🎬 演示四：完整功能演示（8-10分钟）

### 演示大纲

按顺序执行以下演示：

1. **环境准备**（1分钟）
   - 展示项目结构
   - 说明技术栈

2. **快速部署**（2分钟）
   - 参考演示一

3. **用户端功能**（3分钟）
   - 用户注册和登录
   - 浏览和搜索方法
   - 添加到个人库
   - 记录练习
   - 查看统计

4. **管理端功能**（2分钟）
   - 参考演示三

5. **故障排查**（1分钟）
   - 展示日志查看
   - 常见问题处理

6. **总结**（1分钟）
   - 功能回顾
   - 下一步建议

---

## 🎥 GIF 动画建议

### 推荐的 GIF 动画场景

| GIF 名称 | 场景 | 建议尺寸 | 时长 |
|----------|------|----------|------|
| quick-start.gif | 一键部署过程 | 800x600 | 30秒 |
| api-demo.gif | API 请求响应 | 800x400 | 20秒 |
| register-login.gif | 注册登录流程 | 600x400 | 15秒 |
| practice-record.gif | 练习记录过程 | 600x400 | 15秒 |

### GIF 录制工具推荐

**Windows**:
- [ScreenToGif](https://www.screentogif.com/) - 免费、轻量、功能强大
- [LICEcap](https://www.cockos.com/licecap/) - 简单易用

**跨平台**:
- [Gifski](https://gif.ski/) - 高质量 GIF
- [Peek](https://github.com/phw/peek) - Linux 专用

### 录制最佳实践

1. **分辨率**：建议 800x600 或 1024x768
2. **帧率**：10-15 FPS 即可
3. **时长**：单个 GIF 控制在 30 秒以内
4. **文件大小**：控制在 5MB 以内
5. **内容聚焦**：每个 GIF 只展示一个核心功能

---

## 📝 视频脚本模板

### 开场白（10秒）

> "大家好，欢迎来到 Nian 心理自助应用系统的功能演示。今天我将带大家快速了解系统的核心功能。"

### 过渡语

> "接下来，让我们看看..."
> "现在，我们来演示..."
> "最后，让我们验证..."

### 结束语（10秒）

> "以上就是 Nian 系统的功能演示。如果您有任何问题，欢迎查阅文档或提交 Issue。感谢观看！"

---

## 🔧 录制前检查清单

- [ ] Docker Desktop 已启动
- [ ] 项目环境已配置（.env 文件）
- [ ] 终端/PowerShell 窗口已打开
- [ ] 录制软件已准备
- [ ] 麦克风已测试（如需录音）
- [ ] 屏幕分辨率已调整
- [ ] 关闭无关通知和弹窗
- [ ] 准备好演示数据

---

## 📁 演示资源位置

录制完成后，建议将资源放置在以下位置：

```
nian/
├── docs/
│   ├── demo/
│   │   ├── quick-start.gif
│   │   ├── api-demo.gif
│   │   ├── admin-demo.gif
│   │   └── full-demo.mp4
│   └── DEMO_SCRIPT.md (本文档)
└── README.md (添加演示链接)
```

---

**文档版本**: 1.0.0  
**创建日期**: 2024-12-31  
**适用版本**: Nian v1.0.0
