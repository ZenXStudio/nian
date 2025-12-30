# 全平台心理自助应用系统 - 部署指南

## 📦 部署方式

本项目支持Docker一键部署，也支持传统方式部署。

## 🐳 Docker部署（推荐）

### 前置条件

- Docker 20.10 或更高版本
- Docker Compose 2.0 或更高版本
- 至少 4GB 可用内存
- 至少 20GB 可用磁盘空间

### 部署步骤

#### 1. 准备环境

```bash
# 克隆项目（如果还没有）
git clone https://github.com/yourusername/nian.git
cd nian

# 复制环境变量模板
cp .env.example .env
```

#### 2. 配置环境变量

编辑 `.env` 文件，修改以下重要配置：

```bash
# 数据库密码（必须修改）
POSTGRES_PASSWORD=your_secure_password_here

# JWT密钥（必须修改，至少32个字符）
JWT_SECRET=your_jwt_secret_key_here_at_least_32_characters_long

# 其他配置根据需要调整
```

#### 3. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 4. 验证部署

```bash
# 检查后端健康状态
curl http://localhost:3000/health

# 预期输出:
# {"status":"ok","timestamp":"2024-xx-xxTxx:xx:xx.xxxZ"}
```

#### 5. 访问服务

- **后端API**: http://localhost:3000
- **管理后台**: http://localhost:8080 （待实现）
- **数据库**: localhost:5432
- **Redis**: localhost:6379

### 常用Docker命令

```bash
# 查看所有容器状态
docker-compose ps

# 查看特定服务日志
docker-compose logs backend
docker-compose logs postgres

# 重启服务
docker-compose restart backend

# 停止所有服务
docker-compose down

# 停止并删除所有数据（危险操作）
docker-compose down -v

# 重新构建镜像
docker-compose build

# 重新构建并启动
docker-compose up -d --build
```

## 🔧 传统部署方式

### 前置条件

- Node.js 18.x 或更高版本
- PostgreSQL 15.x
- Redis 7.x
- (可选) PM2 进程管理器

### 部署步骤

#### 1. 安装PostgreSQL

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql-15

# 创建数据库和用户
sudo -u postgres psql
CREATE DATABASE mental_app;
CREATE USER mental_app WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE mental_app TO mental_app;
\q
```

#### 2. 导入数据库结构

```bash
psql -U mental_app -d mental_app -f database/init.sql
```

#### 3. 安装Redis

```bash
# Ubuntu/Debian
sudo apt-get install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

#### 4. 部署后端

```bash
cd backend

# 安装依赖
npm install

# 配置环境变量
cp ../.env.example .env
# 编辑.env文件

# 构建TypeScript
npm run build

# 使用PM2启动（推荐）
npm install -g pm2
pm2 start dist/index.js --name mental-app-backend

# 或直接启动
npm start
```

#### 5. 配置Nginx反向代理（可选）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /uploads {
        alias /path/to/nian/uploads;
    }

    location / {
        proxy_pass http://localhost:8080;
    }
}
```

## 🔐 安全配置

### 1. 修改默认密码

**数据库管理员密码**

```sql
-- 连接到数据库
psql -U postgres -d mental_app

-- 生成新的bcrypt hash (使用在线工具或Node.js)
-- 更新管理员密码
UPDATE admins SET password_hash = '$2b$10$NewHashHere' WHERE username = 'admin';
```

**生成bcrypt hash（Node.js）**

```javascript
const bcrypt = require('bcrypt');
const password = 'your_new_password';
bcrypt.hash(password, 10, (err, hash) => {
  console.log(hash);
});
```

### 2. 配置防火墙

```bash
# 仅开放必要端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 3. 启用HTTPS

建议使用Let's Encrypt免费证书:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 监控和维护

### 查看日志

```bash
# Docker方式
docker-compose logs -f backend
docker-compose logs -f postgres

# PM2方式
pm2 logs mental-app-backend
pm2 monit
```

### 数据库备份

```bash
# 创建备份脚本
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/mental-app"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Docker方式备份
docker exec mental-app-postgres pg_dump -U postgres mental_app > $BACKUP_DIR/backup_$DATE.sql

# 保留最近30天的备份
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
EOF

chmod +x backup.sh

# 添加到crontab（每天凌晨2点执行）
crontab -e
# 添加: 0 2 * * * /path/to/backup.sh
```

### 恢复数据库

```bash
# Docker方式
docker exec -i mental-app-postgres psql -U postgres mental_app < backup_file.sql

# 传统方式
psql -U mental_app -d mental_app < backup_file.sql
```

## 🚀 性能优化

### PostgreSQL优化

编辑 `postgresql.conf`:

```conf
# 连接设置
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

### Redis优化

编辑 `redis.conf`:

```conf
maxmemory 512mb
maxmemory-policy allkeys-lru
```

### Node.js优化

```bash
# 使用集群模式
pm2 start dist/index.js -i max --name mental-app-backend
```

## 🐛 故障排查

### 后端无法连接数据库

```bash
# 检查PostgreSQL是否运行
docker-compose ps postgres
# 或
sudo systemctl status postgresql

# 检查连接参数
docker-compose logs postgres
```

### Redis连接失败

```bash
# 检查Redis是否运行
docker-compose ps redis
# 或
sudo systemctl status redis

# 测试Redis连接
redis-cli ping
```

### 文件上传失败

```bash
# 检查uploads目录权限
ls -la uploads/
chmod 755 uploads/
```

## 📝 更新部署

```bash
# 拉取最新代码
git pull origin main

# Docker方式更新
docker-compose down
docker-compose build
docker-compose up -d

# 传统方式更新
cd backend
git pull
npm install
npm run build
pm2 restart mental-app-backend
```

## 💡 生产环境检查清单

- [ ] 修改所有默认密码
- [ ] 设置强JWT密钥
- [ ] 配置HTTPS
- [ ] 设置防火墙规则
- [ ] 配置自动备份
- [ ] 设置监控告警
- [ ] 测试备份恢复
- [ ] 配置日志轮转
- [ ] 优化数据库性能
- [ ] 配置CDN（可选）

## 📞 获取帮助

如遇问题：

1. 查看服务日志
2. 检查环境变量配置
3. 验证数据库连接
4. 查看防火墙设置

---

**部署完成后，请访问 http://your-domain.com/health 验证服务状态**
# 全平台心理自助应用系统 - 部署指南

## 📦 部署方式

本项目支持Docker一键部署，也支持传统方式部署。

## 🐳 Docker部署（推荐）

### 前置条件

- Docker 20.10 或更高版本
- Docker Compose 2.0 或更高版本
- 至少 4GB 可用内存
- 至少 20GB 可用磁盘空间

### 部署步骤

#### 1. 准备环境

```bash
# 克隆项目（如果还没有）
git clone https://github.com/yourusername/nian.git
cd nian

# 复制环境变量模板
cp .env.example .env
```

#### 2. 配置环境变量

编辑 `.env` 文件，修改以下重要配置：

```bash
# 数据库密码（必须修改）
POSTGRES_PASSWORD=your_secure_password_here

# JWT密钥（必须修改，至少32个字符）
JWT_SECRET=your_jwt_secret_key_here_at_least_32_characters_long

# 其他配置根据需要调整
```

#### 3. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 4. 验证部署

```bash
# 检查后端健康状态
curl http://localhost:3000/health

# 预期输出:
# {"status":"ok","timestamp":"2024-xx-xxTxx:xx:xx.xxxZ"}
```

#### 5. 访问服务

- **后端API**: http://localhost:3000
- **管理后台**: http://localhost:8080 （待实现）
- **数据库**: localhost:5432
- **Redis**: localhost:6379

### 常用Docker命令

```bash
# 查看所有容器状态
docker-compose ps

# 查看特定服务日志
docker-compose logs backend
docker-compose logs postgres

# 重启服务
docker-compose restart backend

# 停止所有服务
docker-compose down

# 停止并删除所有数据（危险操作）
docker-compose down -v

# 重新构建镜像
docker-compose build

# 重新构建并启动
docker-compose up -d --build
```

## 🔧 传统部署方式

### 前置条件

- Node.js 18.x 或更高版本
- PostgreSQL 15.x
- Redis 7.x
- (可选) PM2 进程管理器

### 部署步骤

#### 1. 安装PostgreSQL

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql-15

# 创建数据库和用户
sudo -u postgres psql
CREATE DATABASE mental_app;
CREATE USER mental_app WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE mental_app TO mental_app;
\q
```

#### 2. 导入数据库结构

```bash
psql -U mental_app -d mental_app -f database/init.sql
```

#### 3. 安装Redis

```bash
# Ubuntu/Debian
sudo apt-get install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

#### 4. 部署后端

```bash
cd backend

# 安装依赖
npm install

# 配置环境变量
cp ../.env.example .env
# 编辑.env文件

# 构建TypeScript
npm run build

# 使用PM2启动（推荐）
npm install -g pm2
pm2 start dist/index.js --name mental-app-backend

# 或直接启动
npm start
```

#### 5. 配置Nginx反向代理（可选）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /uploads {
        alias /path/to/nian/uploads;
    }

    location / {
        proxy_pass http://localhost:8080;
    }
}
```

## 🔐 安全配置

### 1. 修改默认密码

**数据库管理员密码**

```sql
-- 连接到数据库
psql -U postgres -d mental_app

-- 生成新的bcrypt hash (使用在线工具或Node.js)
-- 更新管理员密码
UPDATE admins SET password_hash = '$2b$10$NewHashHere' WHERE username = 'admin';
```

**生成bcrypt hash（Node.js）**

```javascript
const bcrypt = require('bcrypt');
const password = 'your_new_password';
bcrypt.hash(password, 10, (err, hash) => {
  console.log(hash);
});
```

### 2. 配置防火墙

```bash
# 仅开放必要端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 3. 启用HTTPS

建议使用Let's Encrypt免费证书:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 监控和维护

### 查看日志

```bash
# Docker方式
docker-compose logs -f backend
docker-compose logs -f postgres

# PM2方式
pm2 logs mental-app-backend
pm2 monit
```

### 数据库备份

```bash
# 创建备份脚本
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/mental-app"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Docker方式备份
docker exec mental-app-postgres pg_dump -U postgres mental_app > $BACKUP_DIR/backup_$DATE.sql

# 保留最近30天的备份
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
EOF

chmod +x backup.sh

# 添加到crontab（每天凌晨2点执行）
crontab -e
# 添加: 0 2 * * * /path/to/backup.sh
```

### 恢复数据库

```bash
# Docker方式
docker exec -i mental-app-postgres psql -U postgres mental_app < backup_file.sql

# 传统方式
psql -U mental_app -d mental_app < backup_file.sql
```

## 🚀 性能优化

### PostgreSQL优化

编辑 `postgresql.conf`:

```conf
# 连接设置
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

### Redis优化

编辑 `redis.conf`:

```conf
maxmemory 512mb
maxmemory-policy allkeys-lru
```

### Node.js优化

```bash
# 使用集群模式
pm2 start dist/index.js -i max --name mental-app-backend
```

## 🐛 故障排查

### 后端无法连接数据库

```bash
# 检查PostgreSQL是否运行
docker-compose ps postgres
# 或
sudo systemctl status postgresql

# 检查连接参数
docker-compose logs postgres
```

### Redis连接失败

```bash
# 检查Redis是否运行
docker-compose ps redis
# 或
sudo systemctl status redis

# 测试Redis连接
redis-cli ping
```

### 文件上传失败

```bash
# 检查uploads目录权限
ls -la uploads/
chmod 755 uploads/
```

## 📝 更新部署

```bash
# 拉取最新代码
git pull origin main

# Docker方式更新
docker-compose down
docker-compose build
docker-compose up -d

# 传统方式更新
cd backend
git pull
npm install
npm run build
pm2 restart mental-app-backend
```

## 💡 生产环境检查清单

- [ ] 修改所有默认密码
- [ ] 设置强JWT密钥
- [ ] 配置HTTPS
- [ ] 设置防火墙规则
- [ ] 配置自动备份
- [ ] 设置监控告警
- [ ] 测试备份恢复
- [ ] 配置日志轮转
- [ ] 优化数据库性能
- [ ] 配置CDN（可选）

## 📞 获取帮助

如遇问题：

1. 查看服务日志
2. 检查环境变量配置
3. 验证数据库连接
4. 查看防火墙设置

---

**部署完成后，请访问 http://your-domain.com/health 验证服务状态**
