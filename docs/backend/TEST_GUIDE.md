# 后端API测试指南

## 测试框架

本项目使用以下测试工具：
- **Jest**: JavaScript测试框架
- **Supertest**: HTTP断言库，用于测试Express应用
- **ts-jest**: TypeScript支持

## 测试文件结构

```
backend/
├── src/
│   └── __tests__/
│       └── api.test.ts          # API集成测试
├── jest.config.js               # Jest配置文件
└── package.json                 # 包含测试脚本
```

## 运行测试

### 1. 安装依赖

```bash
cd backend
npm install
```

### 2. 配置测试环境

确保有测试数据库配置，可以创建 `.env.test` 文件：

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mental_app_test
DB_USER=mental_app
DB_PASSWORD=your_password
JWT_SECRET=test_jwt_secret_key
NODE_ENV=test
```

### 3. 运行测试

```bash
# 运行所有测试
npm test

# 运行测试并生成覆盖率报告
npm run test:coverage

# 监视模式（开发时使用）
npm run test:watch

# 运行特定测试文件
npm test -- api.test.ts
```

## 测试用例说明

### 用户认证测试 (User Authentication)

| 用例ID | 描述 | 预期结果 |
|--------|------|----------|
| TC_API_AUTH_001 | 用户注册成功 | 返回201，包含用户信息和token |
| TC_API_AUTH_002 | 无效邮箱格式 | 返回400错误 |
| TC_API_AUTH_003 | 密码过短 | 返回400错误 |
| TC_API_AUTH_004 | 重复邮箱 | 返回409冲突错误 |
| TC_API_AUTH_005 | 登录成功 | 返回200和token |
| TC_API_AUTH_006 | 错误密码 | 返回401错误 |
| TC_API_AUTH_007 | 用户不存在 | 返回401错误 |
| TC_API_AUTH_008 | 获取用户信息 | 返回200和用户详情 |
| TC_API_AUTH_009 | 无token访问 | 返回401错误 |
| TC_API_AUTH_010 | 无效token | 返回401错误 |

### 方法管理测试 (Methods Management)

| 用例ID | 描述 | 预期结果 |
|--------|------|----------|
| TC_API_METHOD_001 | 获取方法列表 | 返回200和方法列表 |
| TC_API_METHOD_002 | 分类筛选 | 返回对应分类的方法 |
| TC_API_METHOD_003 | 分页功能 | 返回指定数量的记录 |
| TC_API_METHOD_004 | 获取方法详情 | 返回200和方法详情 |
| TC_API_METHOD_005 | 方法不存在 | 返回404错误 |

### 管理员功能测试 (Admin Management)

| 用例ID | 描述 | 预期结果 |
|--------|------|----------|
| TC_API_ADMIN_001 | 管理员登录 | 返回200和admin token |
| TC_API_ADMIN_002 | 错误凭据 | 返回401错误 |
| TC_API_ADMIN_003 | 获取用户列表 | 返回200和用户列表 |
| TC_API_ADMIN_004 | 无权限访问 | 返回401错误 |
| TC_API_ADMIN_005 | 获取媒体文件列表 | 返回200和文件列表 |

## 测试覆盖率目标

- **语句覆盖率**: > 80%
- **分支覆盖率**: > 75%
- **函数覆盖率**: > 80%
- **行覆盖率**: > 80%

## 编写新测试

### 测试结构

```typescript
import request from 'supertest';
import { app } from '../index';

describe('Feature Name', () => {
  beforeAll(async () => {
    // 设置测试环境
  });

  afterAll(async () => {
    // 清理测试数据
  });

  describe('API Endpoint', () => {
    it('should do something', async () => {
      const response = await request(app)
        .get('/api/endpoint')
        .send({ data: 'value' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });
});
```

### 最佳实践

1. **使用唯一的测试数据**: 使用时间戳避免数据冲突
2. **清理测试数据**: 在测试后删除创建的数据
3. **测试隔离**: 每个测试应该独立
4. **使用有意义的描述**: 测试描述应该清楚
5. **测试边界条件**: 测试正常和异常情况

## 故障排查

### 测试超时
```typescript
jest.setTimeout(10000); // 10秒
```

### 数据库连接问题
```bash
docker-compose ps postgres
```

---
**版本**: 1.0.0 | **更新**: 2026-01-06
