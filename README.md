# 全平台心理自助应用系统 (Nian)

> 支持 iOS、Android、macOS、Windows 的全平台心理自助应用，提供个性化心理自助方法和进度追踪。

## 项目状态

| 模块 | 完成度 | 状态 |
|------|--------|------|
| 后端API | 100% | ✅ 35个接口 |
| 管理后台 | 100% | ✅ 8个页面 |
| Flutter应用 | 95% | ✅ 12个页面 |
| Docker部署 | 100% | ✅ 一键启动 |

## 核心特性

- ✅ 用户认证（JWT Token）
- ✅ 心理方法浏览、搜索、AI推荐
- ✅ 个人方法库管理
- ✅ 练习记录与统计
- ✅ 管理后台（方法CRUD、审核、统计）
- ✅ Docker一键部署

## 快速启动

```bash
# 1. 配置环境变量
cp .env.example .env
# 编辑 .env，设置 POSTGRES_PASSWORD 和 JWT_SECRET

# 2. 启动服务
docker-compose up -d

# 3. 验证（等待30秒后）
curl http://localhost:3000/health
```

**默认账号**：
- 管理员：admin / admin123456
- 测试用户：注册后使用

## 服务地址

| 服务 | 地址 |
|------|------|
| 后端API | http://localhost:3000 |
| 管理后台 | http://localhost:8080 |

## 技术栈

| 模块 | 技术 |
|------|------|
| 后端 | Node.js + TypeScript + Express |
| 数据库 | PostgreSQL 15 + Redis 7 |
| 管理后台 | React + Ant Design + Vite |
| 移动应用 | Flutter + BLoC |
| 部署 | Docker + Docker Compose |

## 项目结构

```
nian/
├── backend/                # 后端API（Node.js）
├── home/user/nian/admin-web/  # 管理后台（React）
├── flutter_app/            # Flutter应用
├── database/               # 数据库初始化脚本
├── docs/                   # 文档
└── docker-compose.yml      # Docker配置
```

## API概览

### 用户端
| 接口 | 方法 | 路径 |
|------|------|------|
| 注册 | POST | /api/auth/register |
| 登录 | POST | /api/auth/login |
| 方法列表 | GET | /api/methods |
| 方法详情 | GET | /api/methods/:id |
| 添加到库 | POST | /api/user/methods |
| 记录练习 | POST | /api/user/practice |
| 练习统计 | GET | /api/user/practice/statistics |

### 管理端
| 接口 | 方法 | 路径 |
|------|------|------|
| 管理员登录 | POST | /api/admin/login |
| 方法管理 | CRUD | /api/admin/methods |
| 审核 | POST | /api/admin/methods/:id/approve |
| 统计 | GET | /api/admin/statistics/* |

## Flutter应用

### 运行
```bash
cd flutter_app
flutter pub get
flutter run -d windows  # 或 chrome, android
```

### 页面清单
- 启动页、登录、注册
- 方法发现、详情、搜索
- 个人方法库
- 练习历史、统计
- 个人中心

详见：[Flutter架构文档](docs/flutter/ARCHITECTURE.md)

## 文档索引

详细文档请查看 [docs/README.md](docs/README.md)

### 开发文档
| 文档 | 说明 |
|------|------|
| [docs/flutter/SETUP_GUIDE.md](docs/flutter/SETUP_GUIDE.md) | Flutter环境配置 |
| [docs/flutter/ARCHITECTURE.md](docs/flutter/ARCHITECTURE.md) | Flutter架构设计 |
| [docs/flutter/DEVELOPMENT_GUIDE.md](docs/flutter/DEVELOPMENT_GUIDE.md) | Flutter开发规范 |
| [docs/backend/TEST_GUIDE.md](docs/backend/TEST_GUIDE.md) | 后端测试指南 |

### 运维文档
| 文档 | 说明 |
|------|------|
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | 部署指南 |
| [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) | 实施状态 |

## 安全提示

⚠️ 生产环境部署前必须：
1. 修改默认密码（admin/admin123456）
2. 设置强 JWT_SECRET（32+字符）
3. 启用 HTTPS
4. 配置防火墙

## 许可证

MIT License
