# Flutter 移动应用开发完成与 README 更新

## 背景与目标

### 当前状态
根据项目分析，Flutter 应用的基础架构已经搭建完成，包括：
- 配置层：主题、路由、API 常量
- 核心层：网络客户端、错误处理、工具类、本地存储
- 基础 UI 组件：按钮、文本框、加载指示器等

### 待完成内容
- 数据层：数据模型、Repository 实现
- 领域层：业务实体、用例
- 表现层：页面和业务逻辑（BLoC）
- 依赖注入配置
- README 更新

### 开发目标
完成 Flutter 移动应用的核心功能开发，实现与后端 API 的完整集成，并更新 README 文档以反映最新的项目状态和使用指南。

## 架构概览

### 分层架构
遵循 Clean Architecture 原则，应用分为三层：

| 层级 | 职责 | 主要组件 |
|------|------|----------|
| Presentation Layer | UI 展示与交互 | Pages、Widgets、BLoC/Cubit |
| Domain Layer | 业务逻辑 | Entities、Use Cases、Repository 接口 |
| Data Layer | 数据访问 | Repository 实现、Data Sources、Models |

### 依赖规则
- Presentation 依赖 Domain
- Data 依赖 Domain
- Domain 不依赖任何层（最稳定）
- 依赖方向始终向内

## 功能模块设计

### 1. 认证模块

#### 功能范围
- 用户登录
- 用户注册
- 自动登录（Token 验证）
- 登出

#### 数据模型

**User Entity（领域层）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 用户 ID |
| email | String | 邮箱 |
| nickname | String | 昵称 |
| createdAt | DateTime | 注册时间 |

**User Model（数据层）**
扩展 User Entity，添加 JSON 序列化功能

#### 用例

**Login Use Case**
- 输入：email、password
- 输出：Either&lt;Failure, User&gt;
- 职责：验证输入、调用 Repository、返回用户信息或错误

**Register Use Case**
- 输入：email、password、nickname
- 输出：Either&lt;Failure, User&gt;
- 职责：验证输入格式、调用 Repository、返回注册结果

**GetCurrentUser Use Case**
- 输入：无
- 输出：Either&lt;Failure, User&gt;
- 职责：从本地存储获取 Token，验证并返回用户信息

**Logout Use Case**
- 输入：无
- 输出：Either&lt;Failure, void&gt;
- 职责：清除本地 Token 和用户数据

#### 状态管理

**Auth State**

| 状态 | 说明 | 数据 |
|------|------|------|
| AuthInitial | 初始状态 | - |
| AuthLoading | 加载中 | - |
| Authenticated | 已认证 | User |
| Unauthenticated | 未认证 | - |
| AuthError | 错误 | String message |

**Auth Event**

| 事件 | 触发时机 | 参数 |
|------|----------|------|
| AppStarted | 应用启动 | - |
| LoginRequested | 用户点击登录 | email, password |
| RegisterRequested | 用户点击注册 | email, password, nickname |
| LogoutRequested | 用户点击登出 | - |

#### 页面流程

**Splash 页面 → Login 页面流程**
1. 应用启动，展示 Splash 页面
2. 检查本地 Token
3. 如果 Token 存在且有效 → 跳转到 Home 页面
4. 如果 Token 不存在或无效 → 跳转到 Login 页面

**Login 页面流程**
1. 用户输入邮箱和密码
2. 点击登录按钮
3. 表单验证（邮箱格式、密码长度）
4. 发送登录请求
5. 成功：保存 Token，跳转到 Home 页面
6. 失败：显示错误信息

### 2. 方法浏览模块

#### 功能范围
- 浏览方法列表（支持分页）
- 按分类筛选
- 按难度筛选
- 搜索方法
- 查看方法详情

#### 数据模型

**Method Entity**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 方法 ID |
| name | String | 方法名称 |
| description | String | 描述 |
| category | String | 分类 |
| difficulty | String | 难度（简单/中等/困难） |
| durationMinutes | int? | 建议时长（分钟） |
| imageUrl | String? | 封面图片 URL |
| audioUrl | String? | 音频 URL |
| videoUrl | String? | 视频 URL |
| contentJson | Map&lt;String, dynamic&gt; | 方法内容（JSON） |
| viewCount | int | 浏览次数 |
| createdAt | DateTime | 创建时间 |

**Category Enum**

| 值 | 说明 |
|-----|------|
| meditation | 冥想 |
| breathing | 呼吸练习 |
| cognitiveBehavioral | 认知行为 |
| mindfulness | 正念 |
| other | 其他 |

**Difficulty Enum**

| 值 | 说明 |
|-----|------|
| easy | 简单 |
| medium | 中等 |
| hard | 困难 |

#### 用例

**GetMethods Use Case**
- 输入：category（可选）、difficulty（可选）、page、pageSize
- 输出：Either&lt;Failure, List&lt;Method&gt;&gt;
- 职责：获取方法列表，支持筛选和分页

**GetMethodDetail Use Case**
- 输入：methodId
- 输出：Either&lt;Failure, Method&gt;
- 职责：获取方法详情，包含完整内容

**SearchMethods Use Case**
- 输入：keyword、page、pageSize
- 输出：Either&lt;Failure, List&lt;Method&gt;&gt;
- 职责：根据关键词搜索方法

#### 状态管理

**Method List State**

| 状态 | 说明 | 数据 |
|------|------|------|
| MethodListInitial | 初始状态 | - |
| MethodListLoading | 加载中 | - |
| MethodListLoaded | 加载成功 | List&lt;Method&gt;, hasMore |
| MethodListError | 加载失败 | String message |

**Method Detail State**

| 状态 | 说明 | 数据 |
|------|------|------|
| MethodDetailInitial | 初始状态 | - |
| MethodDetailLoading | 加载中 | - |
| MethodDetailLoaded | 加载成功 | Method |
| MethodDetailError | 加载失败 | String message |

#### 页面布局

**Method List 页面**
- 顶部：搜索框
- 筛选栏：分类和难度筛选按钮
- 列表区：方法卡片列表（支持下拉刷新、上拉加载更多）
- 空状态：无数据时展示提示

**Method Detail 页面**
- 顶部：封面图片
- 基本信息：方法名称、分类、难度、时长
- 内容区：方法详细说明（支持富文本）
- 多媒体：音频/视频播放器（如有）
- 底部操作：添加到我的方法库

### 3. 个人方法库模块

#### 功能范围
- 查看我的方法列表
- 添加方法到个人库
- 设置个人目标
- 移除方法
- 查看方法详情

#### 数据模型

**UserMethod Entity**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 记录 ID |
| userId | int | 用户 ID |
| methodId | int | 方法 ID |
| method | Method | 关联的方法信息 |
| personalGoal | String? | 个人目标 |
| isFavorite | bool | 是否收藏 |
| practiceCount | int | 练习次数 |
| addedAt | DateTime | 添加时间 |

#### 用例

**GetUserMethods Use Case**
- 输入：无
- 输出：Either&lt;Failure, List&lt;UserMethod&gt;&gt;
- 职责：获取用户的方法库列表

**AddMethodToLibrary Use Case**
- 输入：methodId、personalGoal（可选）
- 输出：Either&lt;Failure, UserMethod&gt;
- 职责：添加方法到个人库

**UpdateUserMethod Use Case**
- 输入：userMethodId、personalGoal、isFavorite
- 输出：Either&lt;Failure, UserMethod&gt;
- 职责：更新个人方法的目标和收藏状态

**RemoveUserMethod Use Case**
- 输入：userMethodId
- 输出：Either&lt;Failure, void&gt;
- 职责：从个人库移除方法

#### 页面布局

**User Method List 页面**
- 顶部：统计信息（总数、收藏数）
- 标签栏：全部/收藏
- 列表区：用户方法卡片列表
- 卡片内容：方法名称、分类、个人目标、练习次数

### 4. 练习记录模块

#### 功能范围
- 记录练习
- 查看练习历史
- 查看练习统计
- 查看心理状态趋势

#### 数据模型

**PracticeRecord Entity**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 记录 ID |
| userId | int | 用户 ID |
| methodId | int | 方法 ID |
| method | Method? | 关联的方法信息 |
| durationMinutes | int | 练习时长（分钟） |
| moodBefore | int | 练习前心理状态（1-10） |
| moodAfter | int | 练习后心理状态（1-10） |
| notes | String? | 练习笔记 |
| practicedAt | DateTime | 练习时间 |

**PracticeStats Entity**

| 字段 | 类型 | 说明 |
|------|------|------|
| totalCount | int | 总练习次数 |
| totalMinutes | int | 总练习时长 |
| averageMoodImprovement | double | 平均心理状态改善 |
| currentStreak | int | 当前连续天数 |
| longestStreak | int | 最长连续天数 |

#### 用例

**RecordPractice Use Case**
- 输入：methodId、durationMinutes、moodBefore、moodAfter、notes（可选）
- 输出：Either&lt;Failure, PracticeRecord&gt;
- 职责：记录练习

**GetPracticeHistory Use Case**
- 输入：page、pageSize、methodId（可选）
- 输出：Either&lt;Failure, List&lt;PracticeRecord&gt;&gt;
- 职责：获取练习历史列表

**GetPracticeStats Use Case**
- 输入：startDate（可选）、endDate（可选）
- 输出：Either&lt;Failure, PracticeStats&gt;
- 职责：获取练习统计数据

**GetMoodTrend Use Case**
- 输入：days（默认 30）
- 输出：Either&lt;Failure, List&lt;MoodDataPoint&gt;&gt;
- 职责：获取心理状态趋势数据

#### 页面流程

**记录练习流程**
1. 用户在方法详情页点击"开始练习"
2. 进入练习记录页面
3. 用户选择练习前心理状态（1-10 滑块）
4. 开始练习（计时）
5. 练习结束，选择练习后心理状态
6. 可选填写练习笔记
7. 点击保存，记录提交
8. 显示心理状态改善程度

**练习历史页面**
- 顶部：统计卡片（总次数、总时长、平均改善）
- 趋势图：心理状态变化折线图
- 列表区：练习记录卡片列表
- 筛选：按方法筛选

### 5. 个人中心模块

#### 功能范围
- 查看个人信息
- 查看练习统计
- 修改昵称
- 登出

#### 页面布局

**Profile 页面**
- 顶部：用户头像、昵称、邮箱
- 统计区：练习统计卡片
- 设置区：修改昵称、登出

## 数据流设计

### API 请求流程

```
用户操作（点击按钮）
    ↓
Widget 触发事件
    ↓
BLoC 接收事件
    ↓
BLoC 调用 Use Case
    ↓
Use Case 调用 Repository 接口
    ↓
Repository 实现选择数据源
    ↓ (网络请求)
Remote Data Source
    ↓
API Client（Dio）
    ↓
后端 API
    ↓ (返回响应)
Remote Data Source 解析 JSON
    ↓
Repository 转换 Model → Entity
    ↓
Use Case 返回 Either<Failure, Entity>
    ↓
BLoC 更新状态
    ↓
Widget 监听状态变化
    ↓
UI 重建
```

### 错误处理流程

**异常层次结构**

| 异常类型 | 说明 | 触发场景 |
|----------|------|----------|
| ServerException | 服务器错误 | HTTP 状态码 5xx |
| NetworkException | 网络错误 | 连接超时、无网络 |
| ValidationException | 验证错误 | 输入格式错误 |
| CacheException | 缓存错误 | 本地数据读取失败 |
| AuthException | 认证错误 | Token 过期、未授权 |

**Failure 转换**

| Exception | Failure | 用户提示 |
|-----------|---------|----------|
| ServerException | ServerFailure | "服务器错误，请稍后重试" |
| NetworkException | NetworkFailure | "网络连接失败，请检查网络" |
| ValidationException | ValidationFailure | 具体验证错误信息 |
| CacheException | CacheFailure | "数据加载失败" |
| AuthException | AuthFailure | "登录已过期，请重新登录" |

### 缓存策略

**方法列表缓存**
- 策略：网络优先（Network First）
- 缓存时长：30 分钟
- 流程：
  1. 尝试从网络获取
  2. 成功后缓存到本地
  3. 网络失败时从缓存获取

**方法详情缓存**
- 策略：缓存优先（Cache First）
- 缓存时长：永久（直到更新）
- 流程：
  1. 先从缓存获取
  2. 异步从网络更新
  3. 缓存未命中时从网络获取

**用户数据缓存**
- 策略：仅网络（Network Only）
- 不使用缓存，始终获取最新数据

## 本地存储设计

### 存储方案

| 数据类型 | 存储方式 | 说明 |
|----------|----------|------|
| JWT Token | flutter_secure_storage | 加密存储 |
| 用户偏好（主题、语言） | shared_preferences | 键值对存储 |
| 方法列表缓存 | sqflite | 结构化数据 |
| 方法详情缓存 | sqflite | 结构化数据 |

### 数据库表设计

**methods 表**

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INTEGER | PRIMARY KEY | 方法 ID |
| name | TEXT | NOT NULL | 方法名称 |
| description | TEXT | - | 描述 |
| category | TEXT | - | 分类 |
| difficulty | TEXT | - | 难度 |
| duration_minutes | INTEGER | - | 时长 |
| image_url | TEXT | - | 图片 URL |
| audio_url | TEXT | - | 音频 URL |
| video_url | TEXT | - | 视频 URL |
| content_json | TEXT | - | 内容 JSON |
| cached_at | INTEGER | NOT NULL | 缓存时间（时间戳） |

**缓存清理策略**
- 启动时检查缓存时间
- 超过 30 分钟的缓存标记为过期
- 过期缓存在有网络时自动更新

## 依赖注入配置

### 注入策略

使用 get_it + injectable 实现依赖注入

**注入生命周期**

| 类型 | 生命周期 | 说明 | 适用对象 |
|------|----------|------|----------|
| Singleton | 单例 | 应用生命周期内唯一 | DioClient、SecureStorage、Database |
| LazySingleton | 懒加载单例 | 首次使用时创建 | Repository |
| Factory | 工厂 | 每次注入时创建新实例 | BLoC、Use Case |

### 注入顺序

```
1. 核心服务
   - DioClient
   - SecureStorage
   - SharedPreferences
   - Database

2. Data Sources
   - Remote Data Sources
   - Local Data Sources

3. Repositories
   - Repository 实现

4. Use Cases
   - 各模块 Use Cases

5. BLoCs
   - 各模块 BLoCs
```

## 路由设计

### 路由表

| 路径 | 页面 | 说明 |
|------|------|------|
| / | SplashPage | 启动页 |
| /login | LoginPage | 登录页 |
| /register | RegisterPage | 注册页 |
| /home | HomePage | 首页（Tab 导航） |
| /methods | MethodListPage | 方法列表 |
| /methods/:id | MethodDetailPage | 方法详情 |
| /my-methods | UserMethodListPage | 我的方法库 |
| /practice/new | PracticeRecordPage | 记录练习 |
| /practice/history | PracticeHistoryPage | 练习历史 |
| /practice/stats | PracticeStatsPage | 练习统计 |
| /profile | ProfilePage | 个人中心 |

### 导航守卫

**认证守卫**
- 检查 Token 是否存在
- 未登录状态下，除了 login 和 register 页面，其他页面重定向到 login
- 已登录状态下，访问 login 和 register 页面重定向到 home

### 底部导航

HomePage 包含四个 Tab：

| Tab | 图标 | 页面 |
|-----|------|------|
| 首页 | home | 方法推荐、快速入口 |
| 探索 | explore | 方法列表浏览 |
| 我的 | favorite | 我的方法库 |
| 个人 | person | 个人中心 |

## 主题设计

### 颜色规范

**主色调（Primary）**
- 颜色：#2196F3（蓝色）
- 含义：平静、专业、信任
- 应用：AppBar、主按钮、重要操作

**辅助色（Secondary）**
- 颜色：#4CAF50（绿色）
- 含义：成长、健康、积极
- 应用：成功提示、心理改善指标

**语义色**

| 类型 | 颜色 | 应用场景 |
|------|------|----------|
| Success | #4CAF50 | 操作成功、正向反馈 |
| Warning | #FFA726 | 警告提示 |
| Error | #F44336 | 错误提示、删除操作 |
| Info | #2196F3 | 信息提示 |

**难度标识色**

| 难度 | 颜色 | 说明 |
|------|------|------|
| 简单 | #4CAF50（绿色） | 容易上手 |
| 中等 | #FFA726（橙色） | 需要练习 |
| 困难 | #F44336（红色） | 具有挑战 |

### 字体规范

**中文字体**
- 系统默认字体（iOS：PingFang SC，Android：Noto Sans CJK）

**英文字体**
- Roboto（Material Design 标准字体）

**字体大小**

| 用途 | 大小 | 字重 |
|------|------|------|
| 标题 1 | 24sp | Bold |
| 标题 2 | 20sp | Bold |
| 标题 3 | 18sp | Medium |
| 正文 | 16sp | Regular |
| 辅助文本 | 14sp | Regular |
| 说明文本 | 12sp | Regular |

## 性能优化策略

### UI 性能

**优化措施**

| 措施 | 说明 | 收益 |
|------|------|------|
| 使用 const 构造函数 | 减少 Widget 重建 | 降低内存占用、提升渲染性能 |
| ListView.builder | 懒加载列表项 | 降低初始化开销 |
| 图片缓存 | 使用 cached_network_image | 减少网络请求、加快加载速度 |
| 骨架屏 | 使用 shimmer 效果 | 提升加载体验 |
| 防抖和节流 | 限制频繁操作 | 减少无效请求 |

### 网络性能

**优化措施**

| 措施 | 说明 | 收益 |
|------|------|------|
| 请求合并 | 合并多个请求 | 减少请求次数 |
| 分页加载 | 按需加载数据 | 减少单次数据量 |
| 缓存策略 | 合理使用缓存 | 减少网络请求 |
| 图片压缩 | 服务端提供多尺寸图片 | 减少传输数据量 |

### 内存优化

**优化措施**

| 措施 | 说明 |
|------|------|
| 及时释放资源 | BLoC、Controller 销毁时释放 |
| 图片缓存限制 | 设置缓存大小上限 |
| 避免内存泄漏 | 取消未完成的异步操作 |

## 测试策略

### 测试分层

**单元测试（Unit Test）**
- 目标：Use Cases、Repositories、Data Sources
- 覆盖率：80% 以上
- 工具：flutter_test、mockito

**Widget 测试（Widget Test）**
- 目标：独立的 Widget 组件
- 覆盖率：关键 Widget 100%
- 工具：flutter_test

**集成测试（Integration Test）**
- 目标：端到端功能流程
- 覆盖率：核心流程 100%
- 工具：integration_test

### 测试用例设计

**Use Case 测试**
- 成功场景：返回正确的实体
- 失败场景：返回对应的 Failure
- 边界场景：空数据、特殊字符

**BLoC 测试**
- 初始状态：验证初始状态
- 事件处理：验证状态流转
- 错误处理：验证错误状态

**Widget 测试**
- 渲染测试：验证 UI 正确渲染
- 交互测试：验证用户交互响应
- 状态测试：验证状态变化后的 UI

## 安全性设计

### Token 管理

**存储安全**
- 使用 flutter_secure_storage 加密存储
- Token 存储在设备安全区域
- 应用卸载后自动清除

**传输安全**
- 所有 API 请求使用 HTTPS
- Token 通过 Authorization Header 传递
- 格式：Bearer {token}

**过期处理**
- 拦截 401 响应
- 自动清除本地 Token
- 跳转到登录页

### 输入验证

**验证规则**

| 字段 | 规则 |
|------|------|
| 邮箱 | 正则表达式验证格式 |
| 密码 | 长度 6-20 位 |
| 昵称 | 长度 2-20 位，不包含特殊字符 |
| 心理状态评分 | 1-10 整数 |
| 练习时长 | 大于 0 的整数 |

**防护措施**
- 前端验证：提升用户体验
- 后端验证：确保数据安全
- SQL 注入防护：使用参数化查询
- XSS 防护：转义特殊字符

## README 更新内容

### 更新目标
反映 Flutter 应用的最新开发进度和完整功能

### 更新章节

**项目状态更新**
- 将"待实现"的功能模块标记为"已完成"
- 更新功能特性列表
- 补充实际实现的技术细节

**安装运行指南**
- 补充依赖安装步骤
- 添加环境配置说明
- 完善多平台运行命令

**功能演示说明**
- 添加核心功能截图（如有）
- 补充功能使用指南
- 添加常见问题解答

**开发说明**
- 添加代码生成命令说明
- 补充测试运行指南
- 添加构建发布流程

### 更新后的结构

```
# 心理自助应用 - Flutter 客户端

## 项目简介
（保持原有内容）

## 功能特性
- ✅ 用户认证（注册、登录、自动登录）
- ✅ 心理方法浏览和搜索
- ✅ 个性化方法库管理
- ✅ 练习记录与追踪
- ✅ 练习统计与趋势分析
- ✅ Material Design 风格
- ✅ 深色模式支持
- ✅ 安全的 Token 管理

## 技术栈
（保持原有内容，补充实际使用的版本）

## 快速开始

### 前置要求
- Flutter SDK 3.16+ 
- Dart 3.2+
- 对应平台的开发环境

### 安装步骤
1. 克隆仓库
2. 安装依赖：flutter pub get
3. 运行代码生成：flutter pub run build_runner build
4. 配置 API 地址（如需）
5. 运行应用：flutter run

### 运行命令
（详细的多平台运行命令）

## 项目结构
（更新实际的目录结构）

## 核心功能说明
（补充各功能模块的详细说明）

## API 配置
（详细的 API 配置说明）

## 开发指南

### 代码生成
（补充代码生成命令和场景）

### 测试
（补充测试命令和覆盖率要求）

### 构建发布
（补充各平台的构建命令）

## 注意事项
（补充开发和使用中的注意事项）

## 贡献指南
（保持原有内容）

## 许可证
（保持原有内容）
```

## 质量保证

### 代码质量标准

| 指标 | 要求 |
|------|------|
| 代码规范 | 通过 flutter_lints 检查 |
| 注释覆盖 | 公共 API 100% |
| 测试覆盖率 | 核心业务逻辑 80%+ |
| 性能指标 | 应用启动时间 < 3 秒 |

### 交付标准

**代码交付**
- 所有代码通过 Dart 分析器检查
- 关键功能包含单元测试
- 代码格式化规范一致

**文档交付**
- README 更新完整
- 核心模块包含注释说明
- API 调用示例清晰

**功能交付**
- 核心功能可正常运行
- 与后端 API 集成成功
- 错误处理完善

## 风险与依赖

### 技术风险

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| Flutter 版本兼容性 | 中 | 锁定依赖版本，谨慎升级 |
| 多平台适配问题 | 中 | 优先保证 Android/iOS，其他平台按需适配 |
| 网络请求失败 | 高 | 完善错误处理和重试机制 |
| 本地存储失败 | 中 | 提供降级方案（内存缓存） |

### 外部依赖

| 依赖 | 说明 | 影响 |
|------|------|------|
| 后端 API | 需要后端服务正常运行 | 高 |
| 网络环境 | 需要网络连接 | 高 |
| 第三方包 | 依赖社区维护 | 中 |

## 开发优先级

### 第一阶段：核心功能
1. 完成数据层和领域层实现
2. 完成认证模块
3. 完成方法浏览模块

### 第二阶段：扩展功能
1. 完成个人方法库模块
2. 完成练习记录模块
3. 完成个人中心模块

### 第三阶段：优化与测试
1. 添加单元测试
2. 性能优化
3. 更新 README 文档

## 开发规范要求

### 代码风格
- 严格遵循 Dart 代码风格指南
- 使用 dart format 自动格式化
- 通过 flutter analyze 检查

### 命名规范
- 文件名：snake_case
- 类名：PascalCase
- 变量/方法：camelCase
- 常量：lowerCamelCase

### 提交规范
- 提交信息清晰明确
- 功能完整后再提交
- 避免提交调试代码

## 后续优化方向

### 功能增强
- 添加社交功能（分享、评论）
- 添加数据同步功能
- 添加离线模式

### 性能优化
- 实现增量加载
- 优化图片加载策略
- 减少应用体积

### 用户体验
- 添加引导页
- 完善动画效果
- 支持更多手势操作
