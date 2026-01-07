# API文档生成

<cite>
**本文档中引用的文件**  
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts)
- [types/index.ts](file://backend/src/types/index.ts)
- [middleware/errorHandler.ts](file://backend/src/middleware/errorHandler.ts)
- [middleware/auth.ts](file://backend/src/middleware/auth.ts)
- [package.json](file://backend/package.json)
- [tsconfig.json](file://backend/tsconfig.json)
- [TEST_GUIDE.md](file://backend/TEST_GUIDE.md)
- [QUALITY_REPORT.md](file://docs/QUALITY_REPORT.md)
</cite>

## 目录
1. [简介](#简介)
2. [项目结构与技术栈](#项目结构与技术栈)
3. [核心类型定义分析](#核心类型定义分析)
4. [认证接口实现与设计](#认证接口实现与设计)
5. [OpenAPI文档生成方案分析](#openapi文档生成方案分析)
6. [Tsoa集成建议与配置示例](#tsoa集成建议与配置示例)
7. [NPM脚本与自动化流程](#npm脚本与自动化流程)
8. [错误处理与响应结构标准化](#错误处理与响应结构标准化)
9. [类型复用与架构一致性](#类型复用与架构一致性)
10. [结论与实施建议](#结论与实施建议)

## 简介
本文档旨在详细说明如何基于 `auth.routes.ts` 和 `auth.controller.ts` 文件中的 TypeScript 类型与 JSDoc 注释，使用 Tsoa 或 Express OpenAPI 等工具自动生成符合 OpenAPI 3.0 规范的 API 文档。文档将解释装饰器的使用方式、请求参数与响应体的标注方法、HTTP 状态码定义，并展示从路由定义到 YAML 输出的完整流程。同时提供配置文件示例（如 tsoa.json）和 NPM 脚本命令，确保生成的文档包含 JWT 认证信息、统一错误响应格式（AppError），以及用户注册、登录、获取当前用户等接口的具体请求/响应模型。特别强调通过类型复用（如 User、AuthRequest）减少冗余，提升维护效率。

## 项目结构与技术栈
本项目采用分层架构设计，后端基于 Express + TypeScript 构建，具备完整的类型安全机制和模块化结构。关键目录如下：

```
backend/
├── src/
│   ├── controllers/        # 控制器层：业务逻辑处理
│   ├── routes/             # 路由层：接口路径映射
│   ├── middleware/         # 中间件：认证、错误处理
│   ├── types/              # 类型定义：共享接口与模型
│   └── utils/              # 工具函数
```

项目已启用严格的 TypeScript 配置（`strict: true`），并使用 `@types/express` 扩展请求对象类型，为 API 文档自动生成提供了坚实基础。

**Section sources**
- [index.ts](file://backend/src/index.ts#L1-L48)
- [tsconfig.json](file://backend/tsconfig.json#L1-L27)
- [QUALITY_REPORT.md](file://docs/QUALITY_REPORT.md#L59-L94)

## 核心类型定义分析
项目在 `src/types/index.ts` 中集中定义了所有共享类型，支持高度复用和一致性维护。

### 用户与认证相关类型
```typescript
export interface User {
  id: number;
  email: string;
  nickname?: string;
  avatar_url?: string;
  created_at: Date;
  last_login_at?: Date;
  is_active: boolean;
}

export interface UserWithPassword extends User {
  password_hash: string;
}

export interface AuthRequest extends Request {
  user?: { id: number; email: string };
}
```

### 响应与错误类型
```typescript
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: { code: string; message: string };
}

export class AppError extends Error {
  constructor(public statusCode: number, public code: string, message: string) {
    super(message);
  }
}
```

这些类型贯穿整个应用，是生成 OpenAPI 文档中 `schemas` 的理想来源。

**Section sources**
- [types/index.ts](file://backend/src/types/index.ts#L1-L126)
- [middleware/errorHandler.ts](file://backend/src/middleware/errorHandler.ts#L1-L97)
- [middleware/auth.ts](file://backend/src/middleware/auth.ts#L1-L87)

## 认证接口实现与设计
认证功能由 `auth.controller.ts` 实现，通过 `auth.routes.ts` 暴露三个核心接口：

| 接口 | 方法 | 路径 | 是否需要认证 |
|------|------|------|-------------|
| 用户注册 | POST | `/api/auth/register` | 否 |
| 用户登录 | POST | `/api/auth/login` | 否 |
| 获取当前用户 | GET | `/api/auth/me` | 是（JWT） |

### 请求参数与响应结构
- **注册请求体**：`{ email, password, nickname }`
- **登录请求体**：`{ email, password }`
- **成功响应格式**：
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "token": "jwt-token",
      "user": { /* User 类型实例 */ }
    }
  }
  ```
- **错误响应格式**：
  ```json
  {
    "success": false,
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "Email and password are required"
    }
  }
  ```

所有控制器函数均使用 `async/await` 模式，并通过 `AppError` 抛出结构化错误，便于中间件统一处理。

**Section sources**
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L1-L150)
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts#L1-L17)

## OpenAPI文档生成方案分析
尽管项目当前未集成 Tsoa 或 Swagger Decorators，但其代码结构已完全具备自动生成 OpenAPI 文档的条件。以下是两种主流方案的对比分析：

### 方案一：Tsoa（推荐）
Tsoa 是专为 Express + TypeScript 设计的 OpenAPI 生成工具，支持通过装饰器标注路由和参数。

#### 优势
- 原生支持 TypeScript 接口生成 OpenAPI schemas
- 支持从 JSDoc 提取描述信息
- 可生成客户端 SDK
- 与 Express 兼容性好

#### 局限
- 需要修改现有代码以添加装饰器
- 增加构建步骤

### 方案二：Express OpenAPI / Swagger-jsdoc
使用 JSDoc 注释生成文档，无需修改运行时逻辑。

#### 优势
- 零侵入式，仅需添加注释
- 学习成本低
- 快速集成

#### 局限
- 类型推断能力弱于 Tsoa
- 无法直接复用 TypeScript 接口定义

鉴于项目已有完善的类型系统，**推荐采用 Tsoa 方案**以最大化类型复用和文档准确性。

**Section sources**
- [TEST_GUIDE.md](file://backend/TEST_GUIDE.md#L1-L82)
- [package.json](file://backend/package.json#L1-L54)

## Tsoa集成建议与配置示例
为实现 OpenAPI 自动生成，建议进行以下集成步骤。

### 1. 安装依赖
```bash
npm install tsoa swagger-ui-express
npm install -D @types/swagger-ui-express
```

### 2. 创建 tsoa.json 配置文件
```json
{
  "entryFile": "src/index.ts",
  "noImplicitAdditionalProperties": "silently-remove-extras",
  "controllerPathGlobs": ["src/controllers/**/*Controller.ts"],
  "spec": {
    "outputDirectory": "dist",
    "specVersion": 3,
    "securityDefinitions": {
      "bearerAuth": {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT"
      }
    },
    "info": {
      "title": "心理自助应用API",
      "version": "1.0.0",
      "description": "全平台心理自助应用系统后端API"
    },
    "servers": [
      {
        "url": "http://localhost:3000/api",
        "description": "开发环境"
      }
    ]
  },
  "routes": {
    "routesDir": "src",
    "middleware": "express"
  }
}
```

### 3. 修改控制器以支持 Tsoa 装饰器
以 `auth.controller.ts` 为例：

```typescript
import { Route, Post, Get, Body, Security, Response } from 'tsoa';

@Route('auth')
export class AuthController {
  @Post('register')
  @Response<ErrorResponse>(400, 'Validation Error')
  @Response<ErrorResponse>(409, 'Email Already Registered')
  public async register(
    @Body() requestBody: { email: string; password: string; nickname?: string }
  ): Promise<ApiResponse<{ token: string; user: User }>> {
    // 实现逻辑保持不变
  }

  @Post('login')
  @Response<ErrorResponse>(401, 'Invalid Credentials')
  public async login(
    @Body() requestBody: { email: string; password: string }
  ): Promise<ApiResponse<{ token: string; user: User }>> {
    // 实现逻辑保持不变
  }

  @Get('me')
  @Security('bearerAuth')
  public async getCurrentUser(): Promise<ApiResponse<User>> {
    // 实现逻辑保持不变
  }
}
```

### 4. 更新路由文件
将函数式路由改为类路由：

```typescript
// auth.routes.ts
import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';

const router = Router();
const controller = new AuthController();

router.post('/register', controller.register.bind(controller));
router.post('/login', controller.login.bind(controller));
router.get('/me', controller.getCurrentUser.bind(controller));

export default router;
```

**Section sources**
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L1-L150)
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts#L1-L17)

## NPM脚本与自动化流程
在 `package.json` 中添加 Tsoa 构建脚本：

```json
"scripts": {
  "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
  "build": "tsc && tsoa spec-and-routes",
  "start": "node dist/index.js",
  "generate:openapi": "tsoa spec",
  "generate:routes": "tsoa routes",
  "generate:all": "tsoa spec-and-routes",
  "test": "jest --coverage",
  "lint": "eslint . --ext .ts"
}
```

### 构建流程
1. 执行 `npm run generate:all` 生成 `swagger.json` 和路由文件
2. 执行 `npm run build` 编译 TypeScript
3. 启动服务后可通过 `/swagger` 路由查看交互式文档（需集成 `swagger-ui-express`）

### 集成 Swagger UI
在 `src/index.ts` 中添加：

```typescript
import swaggerUi from 'swagger-ui-express';
import * as swaggerDocument from '../dist/swagger.json';

app.use('/swagger', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

**Section sources**
- [package.json](file://backend/package.json#L1-L54)
- [index.ts](file://backend/src/index.ts#L1-L48)

## 错误处理与响应结构标准化
项目已通过 `AppError` 类实现统一错误响应机制，该结构可直接映射为 OpenAPI 的 `ErrorResponse` schema。

### OpenAPI 错误响应定义
```yaml
components:
  schemas:
    ErrorResponse:
      type: object
      required:
        - success
        - error
      properties:
        success:
          type: boolean
          example: false
        error:
          type: object
          required:
            - code
            - message
          properties:
            code:
              type: string
              example: VALIDATION_ERROR
            message:
              type: string
              example: Email and password are required
```

### HTTP 状态码映射
| 状态码 | 含义 | 示例场景 |
|-------|------|---------|
| 200 | 成功 | 登录、获取用户 |
| 201 | 创建成功 | 用户注册 |
| 400 | 参数错误 | 输入验证失败 |
| 401 | 未认证 | 无Token或Token无效 |
| 403 | 权限不足 | 禁用账户登录 |
| 404 | 资源未找到 | 用户不存在 |
| 409 | 冲突 | 邮箱已注册 |
| 500 | 服务器错误 | 数据库异常 |

所有控制器应使用 `@Response` 装饰器明确标注可能的错误状态码。

**Section sources**
- [middleware/errorHandler.ts](file://backend/src/middleware/errorHandler.ts#L1-L97)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L1-L150)

## 类型复用与架构一致性
项目当前的类型定义体系为文档生成提供了极大便利，建议进一步优化以增强可维护性。

### 类型复用策略
1. **统一响应包装器**：所有接口返回 `ApiResponse<T>`
2. **请求体接口提取**：为每个 POST/PUT 接口定义专用输入类型
3. **枚举类型集中管理**：如用户状态、方法分类等

### 示例：提取注册请求类型
```typescript
// types/index.ts
export interface RegisterRequest {
  email: string;
  password: string;
  nickname?: string;
}

// 在控制器中使用
@Post('register')
public async register(
  @Body() requestBody: RegisterRequest
): Promise<ApiResponse<{ token: string; user: User }>> {
  // ...
}
```

### 认证上下文类型
`AuthRequest` 接口已正确扩展 Express Request，确保 `req.user` 类型安全，Tsoa 可自动识别此类型。

**Section sources**
- [types/index.ts](file://backend/src/types/index.ts#L1-L126)
- [middleware/auth.ts](file://backend/src/middleware/auth.ts#L1-L87)

## 结论与实施建议
虽然当前项目尚未集成 OpenAPI 自动生成工具，但其严谨的 TypeScript 类型系统、清晰的分层架构和标准化的错误处理机制，为集成 Tsoa 或类似工具提供了理想基础。

### 实施建议
1. **优先集成 Tsoa**：利用其对 TypeScript 的深度支持，最大化类型复用
2. **渐进式改造**：从认证模块开始，逐步扩展到其他控制器
3. **自动化 CI/CD**：在构建流程中加入文档生成步骤，确保文档与代码同步
4. **文档版本管理**：将生成的 `swagger.json` 纳入版本控制
5. **前端协作**：提供 Swagger UI 地址供前端团队实时查阅

通过以上措施，可实现 API 文档的自动化、标准化和持续化维护，显著提升开发效率和接口可靠性。

**Section sources**
- [QUALITY_REPORT.md](file://docs/QUALITY_REPORT.md#L59-L94)
- [TEST_GUIDE.md](file://backend/TEST_GUIDE.md#L1-L82)
- [package.json](file://backend/package.json#L1-L54)