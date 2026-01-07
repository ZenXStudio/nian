# API端点

<cite>
**本文档中引用的文件**  
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts)
- [method.routes.ts](file://backend/src/routes/method.routes.ts)
- [practice.routes.ts](file://backend/src/routes/practice.routes.ts)
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts)
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts)
- [practice.controller.ts](file://backend/src/controllers/practice.controller.ts)
- [userMethod.controller.ts](file://backend/src/controllers/userMethod.controller.ts)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts)
- [auth.ts](file://backend/src/middleware/auth.ts)
- [errorHandler.ts](file://backend/src/middleware/errorHandler.ts)
- [index.ts](file://backend/src/index.ts)
- [index.ts](file://backend/src/types/index.ts)
</cite>

## 目录
1. [简介](#简介)
2. [API基础信息](#api基础信息)
3. [认证API](#认证api)
4. [方法管理API](#方法管理api)
5. [练习记录API](#练习记录api)
6. [用户方法API](#用户方法api)
7. [管理API](#管理api)
8. [错误响应格式](#错误响应格式)
9. [客户端调用示例](#客户端调用示例)

## 简介
nian后端API为心理自助应用提供完整的RESTful接口服务。API分为多个组，包括用户认证、方法管理、练习记录、用户方法和个人库管理以及管理员功能。所有API端点都遵循统一的响应格式，并使用JWT进行身份验证。本文档详细描述了所有公开的API端点，包括HTTP方法、URL路径、请求头、请求体结构、查询参数、响应格式和状态码。

**API基础信息**
- 基础URL: `http://localhost:3000/api`
- 请求内容类型: `application/json`
- 响应内容类型: `application/json`
- 字符编码: `UTF-8`

## API基础信息

nian后端API采用RESTful架构设计，通过Express框架实现。API端点按功能分组，通过`index.ts`中的路由配置进行组织。所有API响应都遵循统一的格式，包含`success`、`data`、`message`和`error`字段。JWT认证用于保护需要身份验证的端点，通过`Authorization`头传递。

```mermaid
graph TB
A[客户端] --> B[API网关]
B --> C[/api/auth]
B --> D[/api/methods]
B --> E[/api/user/methods]
B --> F[/api/user/practice]
B --> G[/api/admin]
C --> H[auth.controller]
D --> I[method.controller]
E --> J[userMethod.controller]
F --> K[practice.controller]
G --> L[admin.controller]
```

**图源**
- [index.ts](file://backend/src/index.ts#L39-L43)
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts)
- [method.routes.ts](file://backend/src/routes/method.routes.ts)
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts)
- [practice.routes.ts](file://backend/src/routes/practice.routes.ts)
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts)

## 认证API

认证API组提供用户注册、登录和获取当前用户信息的功能。这些端点位于`/api/auth`路径下，由`auth.routes.ts`定义路由，`auth.controller.ts`实现具体逻辑。

### 用户注册
创建新用户账户。

- **HTTP方法**: `POST`
- **URL路径**: `/api/auth/register`
- **请求头**: 
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "email": "string",
  "password": "string",
  "nickname": "string"
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "string",
    "user": {
      "id": 1,
      "email": "string",
      "nickname": "string",
      "avatar_url": "string",
      "created_at": "datetime"
    }
  }
}
```
- **状态码**:
  - `201`: 用户注册成功
  - `400`: 输入验证失败
  - `409`: 邮箱已注册

**节源**
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts#L8)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L9-L68)

### 用户登录
使用邮箱和密码进行身份验证。

- **HTTP方法**: `POST`
- **URL路径**: `/api/auth/login`
- **请求头**: 
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "email": "string",
  "password": "string"
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "string",
    "user": {
      "id": 1,
      "email": "string",
      "nickname": "string",
      "avatar_url": "string",
      "created_at": "datetime"
    }
  }
}
```
- **状态码**:
  - `200`: 登录成功
  - `400`: 输入验证失败
  - `401`: 邮箱或密码无效
  - `403`: 账户被禁用

**节源**
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts#L11)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L71-L125)

### 获取当前用户信息
获取已认证用户的信息。

- **HTTP方法**: `GET`
- **URL路径**: `/api/auth/me`
- **请求头**: 
  - `Authorization: Bearer <token>`
- **响应格式**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "string",
    "nickname": "string",
    "avatar_url": "string",
    "created_at": "datetime",
    "last_login_at": "datetime",
    "is_active": true
  }
}
```
- **状态码**:
  - `200`: 成功获取用户信息
  - `401`: 未认证或令牌无效
  - `404`: 用户未找到

**节源**
- [auth.routes.ts](file://backend/src/routes/auth.routes.ts#L14)
- [auth.controller.ts](file://backend/src/controllers/auth.controller.ts#L128-L149)

## 方法管理API

方法管理API组提供获取方法列表、详情、分类和推荐方法的功能。这些端点位于`/api/methods`路径下，由`method.routes.ts`定义路由，`method.controller.ts`实现具体逻辑。

### 获取方法列表
获取已发布方法的分页列表，支持筛选和搜索。

- **HTTP方法**: `GET`
- **URL路径**: `/api/methods`
- **查询参数**:
  - `category`: 方法分类
  - `difficulty`: 难度级别
  - `keyword`: 搜索关键词
  - `page`: 页码（默认1）
  - `pageSize`: 每页数量（默认20）
- **请求头**: 
  - `Authorization: Bearer <token>`（可选）
- **响应格式**:
```json
{
  "success": true,
  "data": {
    "list": [
      {
        "id": 1,
        "title": "string",
        "description": "string",
        "category": "string",
        "difficulty": "string",
        "duration_minutes": 10,
        "cover_image_url": "string",
        "view_count": 100,
        "select_count": 50,
        "published_at": "datetime"
      }
    ],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```
- **状态码**:
  - `200`: 成功获取方法列表

**节源**
- [method.routes.ts](file://backend/src/routes/method.routes.ts#L8)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts#L7-L73)

### 获取方法分类列表
获取所有方法分类及其数量。

- **HTTP方法**: `GET`
- **URL路径**: `/api/methods/categories`
- **响应格式**:
```json
{
  "success": true,
  "data": [
    {
      "category": "string",
      "count": 10
    }
  ]
}
```
- **状态码**:
  - `200`: 成功获取分类列表

**节源**
- [method.routes.ts](file://backend/src/routes/method.routes.ts#L11)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts#L138-L153)

### 获取推荐方法
获取基于用户偏好的推荐方法列表。

- **HTTP方法**: `GET`
- **URL路径**: `/api/methods/recommend`
- **请求头**: 
  - `Authorization: Bearer <token>`
- **查询参数**:
  - `limit`: 返回数量（默认5）
- **响应格式**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "string",
      "description": "string",
      "category": "string",
      "difficulty": "string",
      "duration_minutes": 10,
      "cover_image_url": "string",
      "select_count": 50
    }
  ]
}
```
- **状态码**:
  - `200`: 成功获取推荐方法
  - `401`: 未认证

**节源**
- [method.routes.ts](file://backend/src/routes/method.routes.ts#L14)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts#L100-L136)

### 获取方法详情
获取特定方法的详细信息。

- **HTTP方法**: `GET`
- **URL路径**: `/api/methods/:id`
- **路径参数**:
  - `id`: 方法ID
- **响应格式**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "string",
    "description": "string",
    "category": "string",
    "difficulty": "string",
    "duration_minutes": 10,
    "cover_image_url": "string",
    "content_json": {},
    "status": "published",
    "view_count": 100,
    "select_count": 50,
    "created_at": "datetime",
    "updated_at": "datetime",
    "published_at": "datetime"
  }
}
```
- **状态码**:
  - `200`: 成功获取方法详情
  - `404`: 方法未找到

**节源**
- [method.routes.ts](file://backend/src/routes/method.routes.ts#L17)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts#L75-L98)

## 练习记录API

练习记录API组提供记录练习、获取练习历史和统计的功能。这些端点位于`/api/user/practice`路径下，由`practice.routes.ts`定义路由，`practice.controller.ts`实现具体逻辑。

### 记录练习
创建新的练习记录。

- **HTTP方法**: `POST`
- **URL路径**: `/api/user/practice`
- **请求头**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "method_id": 1,
  "duration_minutes": 10,
  "mood_before": 5,
  "mood_after": 7,
  "notes": "string",
  "questionnaire_result": {}
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "Practice recorded successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "method_id": 1,
    "practice_date": "date",
    "duration_minutes": 10,
    "mood_before": 5,
    "mood_after": 7,
    "notes": "string",
    "questionnaire_result": {},
    "created_at": "datetime"
  }
}
```
- **状态码**:
  - `201`: 练习记录创建成功
  - `400`: 输入验证失败
  - `401`: 未认证

**节源**
- [practice.routes.ts](file://backend/src/routes/practice.routes.ts#L11)
- [practice.controller.ts](file://backend/src/controllers/practice.controller.ts#L7-L93)

### 获取练习历史
获取用户的练习历史记录。

- **HTTP方法**: `GET`
- **URL路径**: `/api/user/practice`
- **请求头**: 
  - `Authorization: Bearer <token>`
- **查询参数**:
  - `method_id`: 方法ID
  - `start_date`: 开始日期
  - `end_date`: 结束日期
  - `page`: 页码（默认1）
  - `pageSize`: 每页数量（默认20）
- **响应格式**:
```json
{
  "success": true,
  "data": {
    "list": [
      {
        "id": 1,
        "user_id": 1,
        "method_id": 1,
        "practice_date": "date",
        "duration_minutes": 10,
        "mood_before": 5,
        "mood_after": 7,
        "notes": "string",
        "method_title": "string",
        "created_at": "datetime"
      }
    ],
    "total": 10,
    "page": 1,
    "pageSize": 20
  }
}
```
- **状态码**:
  - `200`: 成功获取练习历史
  - `401`: 未认证

**节源**
- [practice.routes.ts](file://backend/src/routes/practice.routes.ts#L14)
- [practice.controller.ts](file://backend/src/controllers/practice.controller.ts#L102-L172)

### 获取练习统计
获取用户的练习统计数据。

- **HTTP方法**: `GET`
- **URL路径**: `/api/user/practice/statistics`
- **请求头**: 
  - `Authorization: Bearer <token>`
- **查询参数**:
  - `period`: 统计周期（week, month, year，默认month）
- **响应格式**:
```json
{
  "success": true,
  "data": {
    "total_practices": 100,
    "total_duration": 500,
    "practice_days": 30,
    "avg_mood_improvement": "0.50",
    "max_continuous_days": 7,
    "mood_trend": [
      {
        "practice_date": "date",
        "avg_mood_before": 5.5,
        "avg_mood_after": 6.2
      }
    ],
    "method_distribution": [
      {
        "id": 1,
        "title": "string",
        "category": "string",
        "practice_count": 10,
        "total_duration": 100
      }
    ]
  }
}
```
- **状态码**:
  - `200`: 成功获取练习统计
  - `401`: 未认证

**节源**
- [practice.routes.ts](file://backend/src/routes/practice.routes.ts#L17)
- [practice.controller.ts](file://backend/src/controllers/practice.controller.ts#L174-L261)

## 用户方法API

用户方法API组提供管理个人方法库的功能。这些端点位于`/api/user/methods`路径下，由`userMethod.routes.ts`定义路由，`userMethod.controller.ts`实现具体逻辑。

### 添加方法到个人库
将方法添加到用户的个人库中。

- **HTTP方法**: `POST`
- **URL路径**: `/api/user/methods`
- **请求头**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "method_id": 1,
  "target_count": 10
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "Method added to your library"
}
```
- **状态码**:
  - `201`: 方法添加成功
  - `400`: 输入验证失败
  - `401`: 未认证
  - `404`: 方法未找到
  - `409`: 方法已在库中

**节源**
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts#L11)
- [userMethod.controller.ts](file://backend/src/controllers/userMethod.controller.ts#L7-L56)

### 获取个人方法列表
获取用户个人方法库中的所有方法。

- **HTTP方法**: `GET`
- **URL路径**: `/api/user/methods`
- **请求头**: 
  - `Authorization: Bearer <token>`
- **响应格式**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "method_id": 1,
      "selected_at": "datetime",
      "target_count": 10,
      "completed_count": 5,
      "total_duration_minutes": 50,
      "continuous_days": 3,
      "last_practice_at": "datetime",
      "is_favorite": true,
      "title": "string",
      "description": "string",
      "category": "string",
      "difficulty": "string",
      "duration_minutes": 10,
      "cover_image_url": "string"
    }
  ]
}
```
- **状态码**:
  - `200`: 成功获取个人方法列表
  - `401`: 未认证

**节源**
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts#L14)
- [userMethod.controller.ts](file://backend/src/controllers/userMethod.controller.ts#L58-L80)

### 更新个人方法
更新个人方法的设置，如目标次数和收藏状态。

- **HTTP方法**: `PUT`
- **URL路径**: `/api/user/methods/:id`
- **路径参数**:
  - `id`: 用户方法ID
- **请求头**: 
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "target_count": 15,
  "is_favorite": true
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "User method updated",
  "data": {
    "id": 1,
    "user_id": 1,
    "method_id": 1,
    "selected_at": "datetime",
    "target_count": 15,
    "completed_count": 5,
    "total_duration_minutes": 50,
    "continuous_days": 3,
    "last_practice_at": "datetime",
    "is_favorite": true
  }
}
```
- **状态码**:
  - `200`: 个人方法更新成功
  - `400`: 输入验证失败
  - `401`: 未认证
  - `404`: 用户方法未找到

**节源**
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts#L17)
- [userMethod.controller.ts](file://backend/src/controllers/userMethod.controller.ts#L82-L131)

### 删除个人方法
从个人库中删除方法。

- **HTTP方法**: `DELETE`
- **URL路径**: `/api/user/methods/:id`
- **路径参数**:
  - `id`: 用户方法ID
- **请求头**: 
  - `Authorization: Bearer <token>`
- **响应格式**:
```json
{
  "success": true,
  "message": "Method removed from your library"
}
```
- **状态码**:
  - `200`: 方法删除成功
  - `401`: 未认证
  - `404`: 用户方法未找到

**节源**
- [userMethod.routes.ts](file://backend/src/routes/userMethod.routes.ts#L20)
- [userMethod.controller.ts](file://backend/src/controllers/userMethod.controller.ts#L133-L162)

## 管理API

管理API组提供管理员功能，包括方法管理、内容审核、数据统计、文件上传和用户管理。这些端点位于`/api/admin`路径下，由`admin.routes.ts`定义路由，`admin.controller.ts`实现具体逻辑。

### 管理员登录
管理员使用用户名和密码进行身份验证。

- **HTTP方法**: `POST`
- **URL路径**: `/api/admin/login`
- **请求头**: 
  - `Content-Type: application/json`
- **请求体**:
```json
{
  "username": "string",
  "password": "string"
}
```
- **响应格式**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "string",
    "admin": {
      "id": 1,
      "username": "string",
      "role": "string",
      "email": "string"
    }
  }
}
```
- **状态码**:
  - `200`: 登录成功
  - `400`: 输入验证失败
  - `401`: 用户名或密码无效
  - `403`: 账户被禁用

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L31)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L9-L66)

### 方法管理
管理员可以创建、更新、删除和审核方法。

- **获取所有方法**:
  - `GET /api/admin/methods` - 获取所有方法（包括草稿）
  - 支持按状态和分类筛选

- **创建方法**:
  - `POST /api/admin/methods` - 创建新方法（初始状态为草稿）
  - 请求体包含方法的所有属性

- **更新方法**:
  - `PUT /api/admin/methods/:id` - 更新现有方法
  - 可以更新方法的任何属性

- **删除方法**:
  - `DELETE /api/admin/methods/:id` - 删除方法

- **提交审核**:
  - `POST /api/admin/methods/:id/submit` - 将草稿提交审核
  - 状态从"draft"变为"pending"

- **审核通过**:
  - `POST /api/admin/methods/:id/approve` - 审核通过并发布
  - 仅超级管理员可执行
  - 状态从"pending"变为"published"

- **审核拒绝**:
  - `POST /api/admin/methods/:id/reject` - 拒绝审核请求
  - 仅超级管理员可执行
  - 状态从"pending"变为"draft"

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L37-L45)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L68-L387)

### 数据统计
管理员可以获取用户和方法的统计数据。

- **获取用户统计**:
  - `GET /api/admin/statistics/users` - 获取用户总数、活跃用户数、新用户数等

- **获取方法统计**:
  - `GET /api/admin/statistics/methods` - 获取已发布方法总数、分类分布、热门方法等

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L48-L49)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L389-L467)

### 文件上传和媒体管理
管理员可以上传文件并管理媒体库。

- **上传文件**:
  - `POST /api/admin/upload` - 上传图片、音频或视频文件
  - 使用`multipart/form-data`格式
  - 文件保存在`uploads`目录

- **获取媒体文件**:
  - `GET /api/admin/media` - 获取媒体文件列表
  - 支持按类型和搜索筛选

- **删除媒体文件**:
  - `DELETE /api/admin/media/:id` - 删除媒体文件
  - 同时删除数据库记录和物理文件

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L52-L54)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L471-L604)

### 数据导出
管理员可以导出用户、方法和练习记录数据。

- **导出用户数据**:
  - `GET /api/admin/export/users` - 导出用户数据
  - 支持CSV和JSON格式

- **导出方法数据**:
  - `GET /api/admin/export/methods` - 导出方法数据
  - 支持CSV和JSON格式

- **导出练习记录**:
  - `GET /api/admin/export/practices` - 导出练习记录
  - 支持CSV、Excel和JSON格式

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L57-L59)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L608-L747)

### 用户管理
管理员可以管理用户账户。

- **获取用户列表**:
  - `GET /api/admin/users` - 获取用户列表
  - 支持搜索、状态筛选和排序

- **获取用户详情**:
  - `GET /api/admin/users/:id` - 获取特定用户详情

- **更新用户状态**:
  - `PUT /api/admin/users/:id/status` - 启用或禁用用户账户

- **获取用户方法**:
  - `GET /api/admin/users/:id/methods` - 获取用户的方法库

- **获取用户练习**:
  - `GET /api/admin/users/:id/practices` - 获取用户的练习记录

**节源**
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L62-L66)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L751-L800)

## 错误响应格式

所有API端点使用统一的错误响应格式。当请求失败时，服务器返回相应的HTTP状态码和JSON格式的错误信息。

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述"
  }
}
```

### 常见错误代码

| 错误代码 | HTTP状态码 | 描述 |
|---------|----------|------|
| VALIDATION_ERROR | 400 | 输入验证失败 |
| AUTH_FAILED | 401 | 认证失败 |
| PERMISSION_DENIED | 403 | 权限不足 |
| NOT_FOUND | 404 | 资源未找到 |
| DUPLICATE_ENTRY | 409 | 重复条目 |
| TOKEN_EXPIRED | 401 | 令牌过期 |
| SERVER_ERROR | 500 | 服务器内部错误 |

错误处理由`errorHandler.ts`中间件实现，捕获所有未处理的异常并返回标准化的错误响应。`AppError`类用于创建具有状态码、代码和消息的自定义应用错误。

**节源**
- [errorHandler.ts](file://backend/src/middleware/errorHandler.ts)
- [index.ts](file://backend/src/index.ts#L51)

## 客户端调用示例

以下示例展示了如何使用不同的客户端调用nian API端点。

### 使用curl调用

```bash
# 用户注册
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "nickname": "用户"
  }'

# 用户登录
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# 获取方法列表（带认证）
curl -X GET http://localhost:3000/api/methods \
  -H "Authorization: Bearer <your-jwt-token>"

# 记录练习
curl -X POST http://localhost:3000/api/user/practice \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "method_id": 1,
    "duration_minutes": 10,
    "mood_before": 5,
    "mood_after": 7
  }'
```

### 使用JavaScript fetch调用

```javascript
// JWT令牌存储
let authToken = null;

// 用户登录函数
async function login(email, password) {
  try {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password })
    });

    const data = await response.json();
    
    if (data.success) {
      authToken = data.data.token;
      // 将令牌存储在localStorage中
      localStorage.setItem('authToken', authToken);
      console.log('登录成功');
    } else {
      console.error('登录失败:', data.error.message);
    }
  } catch (error) {
    console.error('请求失败:', error);
  }
}

// 设置认证头的函数
function getAuthHeaders() {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${authToken}`
  };
}

// 获取方法列表
async function getMethods() {
  try {
    const response = await fetch('/api/methods', {
      method: 'GET',
      headers: getAuthHeaders()
    });

    const data = await response.json();
    
    if (data.success) {
      console.log('方法列表:', data.data);
      return data.data;
    } else {
      console.error('获取方法失败:', data.error.message);
    }
  } catch (error) {
    console.error('请求失败:', error);
  }
}

// 记录练习
async function recordPractice(methodId, duration, moodBefore, moodAfter) {
  try {
    const response = await fetch('/api/user/practice', {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        method_id: methodId,
        duration_minutes: duration,
        mood_before: moodBefore,
        mood_after: moodAfter
      })
    });

    const data = await response.json();
    
    if (data.success) {
      console.log('练习记录成功:', data.data);
      return data.data;
    } else {
      console.error('记录练习失败:', data.error.message);
    }
  } catch (error) {
    console.error('请求失败:', error);
  }
}

// 初始化：从localStorage恢复令牌
function initAuth() {
  const storedToken = localStorage.getItem('authToken');
  if (storedToken) {
    authToken = storedToken;
  }
}

// 使用示例
initAuth();
// login('user@example.com', 'password123');
// getMethods();
// recordPractice(1, 10, 5, 7);
```

**节源**
- [auth.ts](file://backend/src/middleware/auth.ts)
- [index.ts](file://backend/src/index.ts#L40-L43)