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

#### TC_API_AUTH_001: 用户注册成功
- **描述**: 使用有效的邮箱和密码注册新用户
- **预期**: 返回201状态码，包含用户信息和token

#### TC_API_AUTH_002: 无效邮箱格式
- **描述**: 使用无效的邮箱格式注册
- **预期**: 返回400错误

#### TC_API_AUTH_003: 密码过短
- **描述**: 使用少于8位的密码注册
- **预期**: 返回400错误

#### TC_API_AUTH_004: 重复邮箱
- **描述**: 使用已存在的邮箱注册
- **预期**: 返回409冲突错误

#### TC_API_AUTH_005: 登录成功
- **描述**: 使用正确的凭据登录
- **预期**: 返回200状态码和token

#### TC_API_AUTH_006: 错误密码
- **描述**: 使用错误的密码登录
- **预期**: 返回401未授权错误

#### TC_API_AUTH_007: 用户不存在
- **描述**: 使用不存在的邮箱登录
- **预期**: 返回401未授权错误

#### TC_API_AUTH_008: 获取当前用户信息
- **描述**: 使用有效token获取用户信息
- **预期**: 返回200和用户详情

#### TC_API_AUTH_009: 无token访问
- **描述**: 不带token访问需要认证的接口
- **预期**: 返回401错误

#### TC_API_AUTH_010: 无效token
- **描述**: 使用无效token访问接口
- **预期**: 返回401错误

### 方法管理测试 (Methods Management)

#### TC_API_METHOD_001: 获取方法列表
- **描述**: 不需认证，获取已发布的方法列表
- **预期**: 返回200和方法列表

#### TC_API_METHOD_002: 分类筛选
- **描述**: 按分类筛选方法
- **预期**: 返回对应分类的方法

#### TC_API_METHOD_003: 分页功能
- **描述**: 测试分页参数
- **预期**: 返回指定数量的记录

#### TC_API_METHOD_004: 获取方法详情
- **描述**: 通过ID获取方法详情
- **预期**: 返回200和方法详情

#### TC_API_METHOD_005: 方法不存在
- **描述**: 查询不存在的方法ID
- **预期**: 返回404错误

### 管理员功能测试 (Admin Management)

#### TC_API_ADMIN_001: 管理员登录
- **描述**: 使用管理员凭据登录
- **预期**: 返回200和admin token

#### TC_API_ADMIN_002: 错误凭据
- **描述**: 使用错误的管理员密码
- **预期**: 返回401错误

#### TC_API_ADMIN_003: 获取用户列表
- **描述**: 使用admin token获取用户列表
- **预期**: 返回200和用户列表

#### TC_API_ADMIN_004: 无权限访问
- **描述**: 不带admin token访问管理接口
- **预期**: 返回401错误

#### TC_API_ADMIN_005: 获取媒体文件列表
- **描述**: 获取已上传的媒体文件
- **预期**: 返回200和文件列表

### 健康检查测试 (Health Check)

#### TC_API_HEALTH_001: 健康检查
- **描述**: 访问健康检查端点
- **预期**: 返回200和ok状态

## 测试覆盖率目标

- **语句覆盖率**: > 80%
- **分支覆盖率**: > 75%
- **函数覆盖率**: > 80%
- **行覆盖率**: > 80%

## 查看覆盖率报告

运行测试后，覆盖率报告会生成在 `backend/coverage` 目录：

```bash
# 在浏览器中打开HTML报告
open coverage/lcov-report/index.html

# 或在Windows上
start coverage/lcov-report/index.html
```

## 测试数据清理

测试会自动清理创建的测试数据。在 `afterAll` 钩子中：
- 删除测试用户
- 关闭数据库连接

## 编写新测试

### 测试结构

```typescript
import request from 'supertest';
import { app } from '../index';

describe('Feature Name', () => {
  // 测试前准备
  beforeAll(async () => {
    // 设置测试环境
  });

  // 测试后清理
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
   ```typescript
   const email = `test${Date.now()}@example.com`;
   ```

2. **清理测试数据**: 在测试后删除创建的数据
   ```typescript
   afterAll(async () => {
     await pool.query('DELETE FROM users WHERE email LIKE $1', ['test%@example.com']);
   });
   ```

3. **测试隔离**: 每个测试应该独立，不依赖其他测试的结果

4. **使用有意义的描述**: 测试描述应该清楚说明测试内容
   ```typescript
   it('should return 404 when method does not exist', async () => {
     // ...
   });
   ```

5. **测试边界条件**: 不仅测试正常情况，也要测试边界和异常情况

## 持续集成

可以在CI/CD流程中自动运行测试：

```yaml
# .github/workflows/test.yml 示例
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: cd backend && npm install
      - run: cd backend && npm test
```

## 故障排查

### 测试超时

如果测试超时，可以增加超时时间：

```typescript
jest.setTimeout(10000); // 10秒
```

### 数据库连接问题

确保测试数据库正在运行并且配置正确：

```bash
# 检查数据库连接
docker-compose ps postgres
```

### 端口占用

如果端口被占用，可以在测试中使用不同的端口或停止占用端口的服务。

## 下一步

1. 运行现有测试确保所有测试通过
2. 根据需要添加更多测试用例
3. 提高测试覆盖率
4. 集成到CI/CD流程中
