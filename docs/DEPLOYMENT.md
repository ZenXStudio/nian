# 全平台心理自助应用 - 部署指南

## 部署方式

支持 Docker 一键部署（推荐）和传统部署。

## Docker 部署（推荐）

### 前置条件
- Docker 20.10+
- Docker Compose 2.0+
- 4GB+ 内存
- 20GB+ 磁盘空间

### 快速部署

```bash
# 1. 配置环境变量
cp .env.example .env
# 编辑 .env，设置 POSTGRES_PASSWORD 和 JWT_SECRET

# 2. 启动服务
docker-compose up -d

# 3. 等待初始化（约30秒）
# Windows: Start-Sleep -Seconds 30
# Linux/macOS: sleep 30

# 4. 验证
curl http://localhost:3000/health
```

### 服务地址

| 服务 | 地址 |
|------|------|
| 后端API | http://localhost:3000 |
| 管理后台 | http://localhost:8080 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

### 常用命令

```bash
# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f backend

# 重启服务
docker-compose restart backend

# 停止服务
docker-compose down

# 重建并启动
docker-compose up -d --build
```

## 传统部署

### 前置条件
- Node.js 18+
- PostgreSQL 15+
- Redis 7+

### 部署步骤

```bash
# 1. 安装数据库
sudo -u postgres psql
CREATE DATABASE mental_app;
CREATE USER mental_app WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE mental_app TO mental_app;
\q

# 2. 导入数据库
psql -U mental_app -d mental_app -f database/init.sql

# 3. 部署后端
cd backend
npm install
npm run build

# 使用 PM2
pm2 start dist/index.js --name mental-app-backend
```

## 安全配置

### 修改默认密码

```bash
# 生成 bcrypt hash
node -e "require('bcrypt').hash('新密码', 10, (e,h)=>console.log(h))"

# 更新管理员密码
UPDATE admins SET password_hash = '新hash' WHERE username = 'admin';
```

### 启用 HTTPS

```bash
# Let's Encrypt
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 数据库备份

```bash
# 创建备份
docker exec mental-app-postgres pg_dump -U postgres mental_app > backup.sql

# 恢复备份
docker exec -i mental-app-postgres psql -U postgres mental_app < backup.sql
```

## 故障排查

| 问题 | 解决方案 |
|------|---------|
| 端口被占用 | `netstat -ano \| findstr :3000` 找到进程并关闭 |
| 数据库连接失败 | 检查 .env 中的 POSTGRES_PASSWORD |
| API 500 错误 | `docker-compose logs backend` 查看日志 |
| 健康检查失败 | 等待30秒让服务完全启动 |

## 生产环境检查清单

- [ ] 修改默认密码（admin/admin123456）
- [ ] 设置强 JWT_SECRET（32+字符）
- [ ] 配置 HTTPS
- [ ] 设置防火墙
- [ ] 配置自动备份
- [ ] 测试备份恢复

---
**部署完成后访问**: http://localhost:3000/health
