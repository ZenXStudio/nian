# 第四阶段：跨平台移动应用开发完整设计文档

## 项目概述

本文档详细描述Nian心理自助应用第四阶段的Flutter跨平台移动应用开发方案，包括完整功能实现、全面测试体系建设、全平台适配和应用商店发布流程。

### 设计目标

实现一个高质量、全平台支持的心理自助移动应用，满足以下核心要求：

1. 功能完整性：实现所有架构设计文档中规划的功能模块
2. 测试完备性：建立完整的测试体系（单元测试 + Widget测试 + 集成测试 + 端到端测试）
3. 平台全覆盖：支持Android、iOS、Web、Windows、macOS五个平台
4. 生产就绪：具备应用商店发布能力，包含完整的部署和测试文档

### 项目背景

基于前期已完成工作：
- 后端API：35个接口全部实现并可用
- 管理后台：8个页面完整实现
- 数据库：PostgreSQL完整架构（7张表）
- 基础设施：Docker容器化部署
- Flutter骨架：基础项目结构和配置文件

### 设计范围

本设计文档涵盖以下内容：

**开发范围**
- 8个核心功能模块的完整实现
- 60+ Dart文件的代码实现规划
- Clean Architecture三层架构实现
- BLoC状态管理完整实现

**测试范围**
- 单元测试（100%覆盖核心业务逻辑）
- Widget测试（覆盖所有关键UI组件）
- 集成测试（覆盖API交互和数据流）
- 端到端测试（覆盖核心用户流程）

**平台范围**
- Android（API 21+）
- iOS（iOS 12+）
- Web（现代浏览器）
- Windows（Windows 10+）
- macOS（macOS 10.14+）

**发布范围**
- Google Play商店发布准备
- Apple App Store发布准备
- Web部署方案
- Windows应用商店准备
- macOS应用发布准备

---

## 一、架构设计

### 1.1 总体架构

采用Clean Architecture（清洁架构）分层设计，确保代码的可维护性、可测试性和可扩展性。

#### 架构层次关系

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer (表现层)            │
│                                                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐    │
│  │ Widgets │  │  Pages  │  │ BLoC/Cubit  │    │
│  └─────────┘  └─────────┘  └─────────────┘    │
│                                                 │
│  职责：UI展示、用户交互、状态响应               │
│  依赖：仅依赖Domain层                           │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│            Domain Layer (领域层)                 │
│                                                 │
│  ┌─────────┐  ┌──────────┐  ┌──────────────┐  │
│  │Entities │  │Use Cases │  │ Repositories │  │
│  │         │  │          │  │  Interfaces  │  │
│  └─────────┘  └──────────┘  └──────────────┘  │
│                                                 │
│  职责：业务逻辑、业务实体、数据访问接口         │
│  依赖：不依赖任何层（最稳定）                   │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│             Data Layer (数据层)                  │
│                                                 │
│  ┌────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │Repository  │  │Remote Data  │  │ Local   │ │
│  │   Impl     │  │   Source    │  │  Data   │ │
│  └────────────┘  └─────────────┘  └─────────┘ │
│                                                 │
│  职责：数据获取、数据转换、缓存管理             │
│  依赖：实现Domain层定义的接口                   │
└─────────────────────────────────────────────────┘
```

#### 层级职责详解

**Presentation Layer（表现层）**

职责定义：
- 展示UI界面
- 处理用户输入和交互
- 响应状态变化并更新UI
- 路由导航管理

组件构成：
- Pages：完整的页面组件
- Widgets：可复用的UI组件
- BLoC/Cubit：状态管理和业务逻辑协调器

设计约束：
- 不包含任何业务逻辑
- 不直接调用数据源
- 仅通过BLoC与Domain层通信
- UI组件应尽可能解耦和可复用

**Domain Layer（领域层）**

职责定义：
- 定义核心业务实体
- 实现业务规则和逻辑
- 定义数据访问接口（不实现）
- 封装单一用例操作

组件构成：
- Entities：纯Dart业务实体对象
- Use Cases：单一职责的业务用例
- Repository Interfaces：数据访问抽象接口

设计约束：
- 不依赖Flutter框架
- 不依赖外部库（除基础Dart）
- 作为整个架构的核心和最稳定层
- 所有业务逻辑必须在此层实现

**Data Layer（数据层）**

职责定义：
- 实现Repository接口
- 处理远程和本地数据源
- 数据模型与实体的转换
- 缓存策略实现

组件构成：
- Repository Implementations：实现Domain层定义的接口
- Remote Data Source：网络API调用
- Local Data Source：本地数据库和缓存
- Models：带序列化的数据传输对象

设计约束：
- 实现Domain层的接口契约
- 处理所有数据获取异常
- 负责数据转换（Model ↔ Entity）
- 实现离线缓存策略

### 1.2 状态管理架构

采用BLoC（Business Logic Component）模式进行状态管理。

#### BLoC模式设计原则

**核心概念**

Events（事件）：
- 描述用户操作或系统事件
- 不可变的数据类
- 清晰命名表达意图

States（状态）：
- 描述UI的不同状态
- 不可变的数据类
- 包含UI渲染所需的所有数据

BLoC（业务逻辑组件）：
- 接收Events
- 执行业务逻辑（调用Use Cases）
- 发射新的States

**状态流转模式**

```
用户操作 → Event → BLoC → Use Case → Repository 
                    ↓
                  State → UI更新
```

典型状态定义：
- Initial：初始状态
- Loading：加载中状态
- Success：成功状态（包含数据）
- Failure：失败状态（包含错误信息）
- Empty：空数据状态

**BLoC设计规范**

单一职责：
- 每个BLoC只管理一个功能模块
- 避免BLoC之间的直接依赖
- 通过Repository共享数据

状态不可变：
- 使用Equatable实现状态相等性比较
- 所有状态类使用final字段
- 避免在State中存储可变对象

错误处理：
- 统一的错误状态定义
- 友好的错误消息
- 错误日志记录

测试友好：
- BLoC应易于单元测试
- 通过依赖注入传递Use Cases
- 避免在BLoC中直接访问全局状态

### 1.3 依赖注入架构

使用GetIt + Injectable实现依赖注入，支持自动代码生成。

#### 依赖注入层次

```
Application Level（应用级）
  ├── API Client（网络客户端）
  ├── Local Database（本地数据库）
  ├── Secure Storage（安全存储）
  └── Shared Preferences（配置存储）

Repository Level（仓库级）
  ├── Auth Repository
  ├── Method Repository
  ├── User Method Repository
  └── Practice Repository

Use Case Level（用例级）
  ├── Login Use Case
  ├── Get Methods Use Case
  ├── Record Practice Use Case
  └── ... (其他用例)

BLoC Level（BLoC级）
  ├── Auth BLoC
  ├── Method BLoC
  ├── Practice BLoC
  └── ... (其他BLoCs)
```

#### 注册策略

Singleton（单例）：
- API Client：整个应用生命周期
- Local Database：整个应用生命周期
- Storage Services：整个应用生命周期

Factory（工厂）：
- Repositories：每次使用时创建新实例
- Use Cases：每次使用时创建新实例
- BLoCs：每个页面创建独立实例

LazySingleton（懒单例）：
- 大型服务在首次使用时初始化
- 减少应用启动时间

### 1.4 数据流架构

#### API请求数据流

完整的数据请求流程：

```
1. UI触发操作
   ↓
2. Widget发送Event到BLoC
   ↓
3. BLoC接收Event并发射Loading状态
   ↓
4. BLoC调用对应的Use Case
   ↓
5. Use Case调用Repository接口
   ↓
6. Repository决定数据源（Remote/Local/Cache）
   ↓
7. Remote Data Source执行API调用
   ↓
8. 接收响应并转换Model → Entity
   ↓
9. Repository返回Either<Failure, Entity>
   ↓
10. Use Case处理结果
   ↓
11. BLoC根据结果发射Success或Failure状态
   ↓
12. Widget监听状态变化并更新UI
```

#### 缓存策略设计

**网络优先策略（Network First）**

适用场景：
- 需要实时数据的场景
- 数据更新频繁的接口
- 方法列表、推荐数据等

流程描述：
1. 优先从网络获取最新数据
2. 成功后更新本地缓存
3. 网络失败时降级使用缓存数据
4. 缓存也失败时返回错误

**缓存优先策略（Cache First）**

适用场景：
- 数据变化不频繁
- 需要快速响应的场景
- 方法详情、用户信息等

流程描述：
1. 先检查本地缓存
2. 缓存存在且未过期则直接返回
3. 后台异步更新缓存数据
4. 缓存不存在时从网络获取

**仅缓存策略（Cache Only）**

适用场景：
- 用户个人数据
- 已下载的内容
- 离线模式下的数据访问

流程描述：
1. 仅从本地缓存读取
2. 不进行网络请求
3. 缓存不存在返回空

**缓存过期策略**

时间策略：
- 方法列表：1小时过期
- 方法详情：24小时过期
- 用户信息：15分钟过期
- 推荐数据：30分钟过期

容量策略：
- 图片缓存最大100MB
- 数据库缓存最大50MB
- 超出限制时清理最旧数据

### 1.5 错误处理架构

#### 错误分类体系

**Exception（异常）**

服务器异常（ServerException）：
- HTTP错误（4xx, 5xx）
- 网络超时
- 服务器无响应

缓存异常（CacheException）：
- 数据库读写失败
- 缓存数据损坏
- 存储空间不足

验证异常（ValidationException）：
- 输入参数不合法
- 业务规则验证失败

网络异常（NetworkException）：
- 无网络连接
- DNS解析失败
- 连接中断

**Failure（失败）**

在Domain层定义的业务失败类型：

- ServerFailure：服务器端错误
- CacheFailure：缓存相关错误
- ValidationFailure：验证失败
- NetworkFailure：网络连接失败
- UnauthorizedFailure：认证失败

#### 错误处理流程

Data Layer（数据层）：
- 捕获所有异常
- 转换为对应的Exception类型
- 记录错误日志

Repository Layer（仓库层）：
- 将Exception转换为Failure
- 使用Either类型返回结果
- Either<Failure, Data>

Domain Layer（领域层）：
- Use Cases返回Either<Failure, Entity>
- 不处理具体错误，只传递结果

Presentation Layer（表现层）：
- BLoC处理Failure并转换为用户友好的错误消息
- UI显示错误提示
- 提供重试机制

---

## 二、功能模块设计

### 2.1 认证模块（Authentication Module）

#### 功能概述

实现用户注册、登录、登出和身份验证功能，确保用户数据安全。

#### 核心功能清单

用户注册：
- 邮箱和密码注册
- 邮箱格式验证
- 密码强度检查
- 昵称设置
- 自动登录

用户登录：
- 邮箱密码登录
- 记住登录状态
- JWT Token管理
- 自动刷新Token

用户登出：
- 清除本地Token
- 清除用户信息
- 重置应用状态
- 跳转到登录页

身份验证：
- Token有效性检查
- 自动登录检测
- 401错误处理
- 会话过期提示

#### 实体设计

User实体：
- id：用户唯一标识
- email：邮箱地址
- nickname：用户昵称
- avatarUrl：头像URL（可选）
- createdAt：注册时间

AuthToken实体：
- token：JWT令牌
- refreshToken：刷新令牌（可选）
- expiresAt：过期时间

#### 用例设计

Login Use Case：
- 输入：email, password
- 输出：Either<Failure, User>
- 业务逻辑：调用Repository登录并保存Token

Register Use Case：
- 输入：email, password, nickname
- 输出：Either<Failure, User>
- 业务逻辑：验证输入并调用Repository注册

Logout Use Case：
- 输入：无
- 输出：Either<Failure, Unit>
- 业务逻辑：清除本地Token和用户信息

GetCurrentUser Use Case：
- 输入：无
- 输出：Either<Failure, User>
- 业务逻辑：从缓存或API获取当前用户信息

CheckAuthStatus Use Case：
- 输入：无
- 输出：bool（是否已登录）
- 业务逻辑：检查Token是否存在且有效

#### 状态设计

AuthState状态类型：
- AuthInitial：初始状态
- AuthLoading：认证处理中
- Authenticated：已认证（包含User）
- Unauthenticated：未认证
- AuthError：认证错误（包含错误消息）

AuthEvent事件类型：
- AppStarted：应用启动，检查登录状态
- LoginRequested：请求登录
- RegisterRequested：请求注册
- LogoutRequested：请求登出
- AuthStatusChanged：认证状态变化

#### UI页面设计

登录页面（LoginPage）：

页面结构：
- 应用Logo和标题
- 邮箱输入框
- 密码输入框（支持显示/隐藏）
- 记住我选项
- 登录按钮
- 注册链接
- 忘记密码链接

交互逻辑：
- 实时输入验证
- 登录按钮在输入有效时激活
- 加载状态显示进度指示器
- 登录成功跳转到首页
- 登录失败显示错误提示

注册页面（RegisterPage）：

页面结构：
- 邮箱输入框
- 昵称输入框
- 密码输入框
- 确认密码输入框
- 用户协议复选框
- 注册按钮
- 已有账号登录链接

交互逻辑：
- 实时验证所有输入
- 密码强度指示器
- 确认密码匹配检查
- 注册成功自动登录并跳转

启动页面（SplashPage）：

页面结构：
- 应用Logo和启动动画
- 加载进度指示器
- 版本号显示

交互逻辑：
- 自动检查登录状态
- 已登录跳转到首页
- 未登录跳转到登录页
- 检查失败显示错误

#### 安全机制设计

Token存储：
- 使用flutter_secure_storage加密存储
- Token与设备绑定
- 定期刷新Token

密码处理：
- 前端不存储密码明文
- 传输使用HTTPS
- 符合后端加密要求

会话管理：
- Token过期自动登出
- 401响应自动跳转登录
- 后台切换检查会话有效性

### 2.2 方法浏览模块（Method Browse Module）

#### 功能概述

用户浏览和搜索心理自助方法，支持分类筛选、搜索和详情查看。

#### 核心功能清单

方法列表浏览：
- 分页加载方法列表
- 下拉刷新
- 上拉加载更多
- 列表项展示核心信息
- 快速滚动支持

方法搜索：
- 关键词搜索
- 搜索历史记录
- 搜索建议
- 实时搜索结果

分类筛选：
- 按分类筛选（情绪管理、压力缓解等）
- 按难度筛选（初级、中级、高级）
- 按时长筛选（<10分钟、10-30分钟、>30分钟）
- 多条件组合筛选

方法详情：
- 完整方法信息展示
- 步骤说明
- 多媒体内容（图片、音频、视频）
- 使用提示
- 添加到个人库按钮
- 开始练习按钮

智能推荐：
- 基于用户历史的个性化推荐
- 热门方法推荐
- 相似方法推荐

#### 实体设计

Method实体：
- id：方法唯一标识
- name：方法名称
- description：方法描述
- category：分类
- difficulty：难度等级
- durationMinutes：预计时长
- steps：步骤列表
- imageUrl：封面图片
- audioUrl：音频URL（可选）
- videoUrl：视频URL（可选）
- viewCount：浏览次数
- tips：使用提示
- benefits：预期效果
- createdAt：创建时间

Category实体：
- id：分类ID
- name：分类名称
- icon：分类图标
- description：分类描述
- methodCount：方法数量

#### 用例设计

GetMethods Use Case：
- 输入：page, pageSize, category, difficulty, searchKeyword
- 输出：Either<Failure, PaginatedMethods>
- 业务逻辑：根据条件查询方法列表

GetMethodDetail Use Case：
- 输入：methodId
- 输出：Either<Failure, Method>
- 业务逻辑：获取方法详细信息并增加浏览次数

SearchMethods Use Case：
- 输入：keyword, filters
- 输出：Either<Failure, List<Method>>
- 业务逻辑：关键词搜索并应用筛选条件

GetMethodsByCategory Use Case：
- 输入：categoryId, page, pageSize
- 输出：Either<Failure, PaginatedMethods>
- 业务逻辑：获取指定分类的方法列表

GetRecommendedMethods Use Case：
- 输入：userId, limit
- 输出：Either<Failure, List<Method>>
- 业务逻辑：基于用户历史获取推荐方法

GetCategories Use Case：
- 输入：无
- 输出：Either<Failure, List<Category>>
- 业务逻辑：获取所有分类列表

#### 状态设计

MethodListState状态类型：
- MethodListInitial：初始状态
- MethodListLoading：加载中
- MethodListLoaded：已加载（包含方法列表）
- MethodListLoadingMore：加载更多中
- MethodListError：加载错误
- MethodListEmpty：无数据

MethodDetailState状态类型：
- MethodDetailInitial：初始状态
- MethodDetailLoading：加载中
- MethodDetailLoaded：已加载（包含方法详情）
- MethodDetailError：加载错误

MethodSearchState状态类型：
- SearchInitial：初始状态
- SearchLoading：搜索中
- SearchLoaded：搜索结果已加载
- SearchEmpty：无搜索结果
- SearchError：搜索错误

#### UI页面设计

方法列表页面（MethodListPage）：

页面结构：
- 顶部搜索栏
- 分类标签横向滚动
- 筛选按钮
- 方法列表（卡片式布局）
- 加载指示器

卡片内容：
- 封面图片
- 方法名称
- 分类标签
- 难度标签
- 时长标签
- 浏览次数
- 简短描述

交互逻辑：
- 下拉刷新重新加载
- 滚动到底部自动加载更多
- 点击卡片进入详情页
- 点击分类标签筛选
- 点击搜索栏进入搜索页

方法详情页面（MethodDetailPage）：

页面结构：
- 顶部图片轮播（如有多图）
- 方法标题和基本信息
- 标签栏（难度、分类、时长）
- 方法描述
- 步骤列表（可展开折叠）
- 使用提示
- 预期效果说明
- 多媒体内容（音频/视频播放器）
- 底部操作栏（添加到个人库、开始练习）

交互逻辑：
- 图片点击全屏查看
- 音频/视频可播放
- 步骤列表可展开查看详细
- 添加到个人库后按钮状态变化
- 开始练习跳转到练习页面

搜索页面（MethodSearchPage）：

页面结构：
- 搜索输入框
- 搜索历史（可清除）
- 热门搜索标签
- 搜索结果列表
- 筛选面板（侧滑或底部弹出）

交互逻辑：
- 实时搜索（防抖处理）
- 点击历史或热门标签快速搜索
- 搜索结果支持筛选
- 无结果时显示空状态
- 清除按钮清空输入

筛选面板（FilterSheet）：

筛选选项：
- 分类多选
- 难度单选
- 时长范围选择
- 排序方式（最新、最热、评分）

交互逻辑：
- 实时预览筛选结果数量
- 重置按钮清除所有筛选
- 确认按钮应用筛选
- 筛选条件持久化保存

### 2.3 个人方法库模块（User Method Library Module）

#### 功能概述

用户管理自己的方法收藏库，设置个人目标和练习计划。

#### 核心功能清单

添加方法到个人库：
- 从方法详情添加
- 设置个人目标
- 选择提醒频率
- 添加个人备注

个人方法列表：
- 显示所有已添加的方法
- 按分类分组展示
- 按收藏状态筛选
- 按添加时间排序

方法管理：
- 编辑个人目标
- 设置/取消收藏
- 查看练习进度
- 删除方法

练习提醒：
- 设置提醒时间
- 提醒频率选择（每天、每周）
- 推送通知
- 提醒历史记录

#### 实体设计

UserMethod实体：
- id：记录唯一标识
- userId：用户ID
- methodId：方法ID
- method：关联的方法实体
- personalGoal：个人目标
- isFavorite：是否收藏
- reminderEnabled：是否启用提醒
- reminderTime：提醒时间
- reminderFrequency：提醒频率
- notes：个人备注
- practiceCount：练习次数
- totalDurationMinutes：累计练习时长
- lastPracticeAt：最后练习时间
- addedAt：添加时间

#### 用例设计

AddMethodToLibrary Use Case：
- 输入：methodId, personalGoal, reminderSettings
- 输出：Either<Failure, UserMethod>
- 业务逻辑：添加方法到个人库并设置目标

GetUserMethods Use Case：
- 输入：userId, filters
- 输出：Either<Failure, List<UserMethod>>
- 业务逻辑：获取用户的方法库列表

UpdateUserMethod Use Case：
- 输入：userMethodId, updates
- 输出：Either<Failure, UserMethod>
- 业务逻辑：更新个人目标、收藏状态等

RemoveUserMethod Use Case：
- 输入：userMethodId
- 输出：Either<Failure, Unit>
- 业务逻辑：从个人库删除方法

ToggleFavorite Use Case：
- 输入：userMethodId
- 输出：Either<Failure, UserMethod>
- 业务逻辑：切换方法的收藏状态

UpdateReminderSettings Use Case：
- 输入：userMethodId, reminderSettings
- 输出：Either<Failure, UserMethod>
- 业务逻辑：更新提醒设置

#### 状态设计

UserMethodState状态类型：
- UserMethodInitial：初始状态
- UserMethodLoading：加载中
- UserMethodLoaded：已加载（包含方法列表）
- UserMethodOperating：操作进行中
- UserMethodError：操作错误
- UserMethodEmpty：无数据

#### UI页面设计

个人方法库页面（UserMethodListPage）：

页面结构：
- 顶部统计卡片（总方法数、练习次数、累计时长）
- 筛选标签（全部、收藏、最近添加）
- 方法列表（卡片式）
- 浮动添加按钮

卡片内容：
- 方法信息
- 个人目标显示
- 练习进度条
- 收藏图标
- 快捷操作按钮

交互逻辑：
- 下拉刷新
- 滑动删除方法
- 点击卡片查看详情
- 长按显示更多操作
- 空状态引导添加

个人方法详情页（UserMethodDetailPage）：

页面结构：
- 方法基本信息
- 个人目标编辑区
- 练习统计图表
- 练习历史列表
- 提醒设置区域
- 个人备注区域

交互逻辑：
- 编辑个人目标
- 查看详细统计
- 跳转到练习页面
- 设置提醒
- 添加/编辑备注

添加方法对话框（AddMethodDialog）：

对话框内容：
- 方法基本信息预览
- 个人目标输入框
- 提醒设置选项
- 备注输入框
- 确认和取消按钮

交互逻辑：
- 验证输入
- 提交后刷新列表
- 成功后显示提示

### 2.4 练习记录模块（Practice Record Module）

#### 功能概述

记录用户的练习过程，追踪心理状态变化，提供统计分析。

#### 核心功能清单

练习记录：
- 选择练习方法
- 记录练习时长
- 练习前心理状态评分
- 练习后心理状态评分
- 添加练习笔记
- 记录练习感受

练习历史：
- 按时间查看历史记录
- 按方法筛选记录
- 日历视图显示
- 记录详情查看

练习统计：
- 总练习次数
- 累计练习时长
- 平均练习时长
- 练习频率统计
- 心理状态改善趋势
- 最常练习的方法

数据可视化：
- 心理状态趋势图
- 练习频率柱状图
- 方法分布饼图
- 每周练习热力图

#### 实体设计

PracticeRecord实体：
- id：记录唯一标识
- userId：用户ID
- methodId：方法ID
- method：关联的方法实体
- durationMinutes：练习时长
- moodBefore：练习前心情评分（1-5）
- moodAfter：练习后心情评分（1-5）
- notes：练习笔记
- tags：标签列表
- practiceDate：练习日期
- createdAt：记录时间

PracticeStatistics实体：
- totalPractices：总练习次数
- totalDurationMinutes：总练习时长
- averageDurationMinutes：平均时长
- averageMoodImprovement：平均心情改善
- practiceStreak：连续练习天数
- mostPracticedMethod：最常练习的方法
- weeklyPracticeCount：每周练习次数

MoodTrend实体：
- date：日期
- averageMoodBefore：平均练习前心情
- averageMoodAfter：平均练习后心情
- practiceCount：当天练习次数

#### 用例设计

RecordPractice Use Case：
- 输入：methodId, duration, moodBefore, moodAfter, notes
- 输出：Either<Failure, PracticeRecord>
- 业务逻辑：记录练习并更新统计数据

GetPracticeHistory Use Case：
- 输入：userId, startDate, endDate, methodId
- 输出：Either<Failure, List<PracticeRecord>>
- 业务逻辑：获取指定时间范围的练习历史

GetPracticeStatistics Use Case：
- 输入：userId, period
- 输出：Either<Failure, PracticeStatistics>
- 业务逻辑：计算并返回练习统计数据

GetMoodTrend Use Case：
- 输入：userId, startDate, endDate
- 输出：Either<Failure, List<MoodTrend>>
- 业务逻辑：获取心理状态变化趋势数据

DeletePracticeRecord Use Case：
- 输入：recordId
- 输出：Either<Failure, Unit>
- 业务逻辑：删除练习记录

#### 状态设计

PracticeState状态类型：
- PracticeInitial：初始状态
- PracticeRecording：记录进行中
- PracticeRecorded：记录成功
- PracticeError：记录失败

PracticeHistoryState状态类型：
- HistoryInitial：初始状态
- HistoryLoading：加载中
- HistoryLoaded：已加载（包含历史记录）
- HistoryEmpty：无历史记录
- HistoryError：加载错误

PracticeStatsState状态类型：
- StatsInitial：初始状态
- StatsLoading：加载中
- StatsLoaded：已加载（包含统计数据）
- StatsError：加载错误

#### UI页面设计

练习记录页面（PracticeRecordPage）：

页面结构：
- 方法信息卡片
- 计时器（可选）
- 练习前心情评分滑块
- 练习后心情评分滑块
- 时长输入
- 笔记输入框
- 标签选择
- 完成按钮

交互逻辑：
- 计时器开始/暂停/停止
- 心情滑块实时预览
- 输入验证
- 提交后跳转到成功页面
- 支持快速重复练习

练习历史页面（PracticeHistoryPage）：

页面结构：
- 顶部统计卡片
- 日期筛选器
- 日历视图/列表视图切换
- 练习记录列表
- 筛选和排序按钮

列表项内容：
- 日期和时间
- 方法名称
- 时长
- 心情变化（图标或数字）
- 快速查看笔记

交互逻辑：
- 切换日历/列表视图
- 按日期范围筛选
- 按方法筛选
- 点击查看详情
- 滑动删除记录

练习统计页面（PracticeStatsPage）：

页面结构：
- 时间范围选择器（周/月/年/全部）
- 总览统计卡片组
  - 总练习次数
  - 累计时长
  - 平均改善
  - 连续天数
- 心情趋势图表
- 练习频率图表
- 方法分布图表
- 热力图日历

交互逻辑：
- 切换时间范围实时更新
- 图表可交互（点击查看详情）
- 数据导出功能
- 分享统计成果

练习详情页（PracticeDetailPage）：

页面结构：
- 日期和时间
- 方法信息
- 时长显示
- 心情变化对比
- 完整笔记显示
- 标签列表
- 编辑和删除按钮

交互逻辑：
- 支持编辑笔记
- 删除需要确认
- 查看关联方法详情

### 2.5 多媒体播放模块（Media Player Module）

#### 功能概述

支持音频和视频的播放，为冥想引导音频和教学视频提供播放功能。

#### 核心功能清单

音频播放：
- 播放/暂停控制
- 进度条拖动
- 播放速度调节（0.5x - 2x）
- 循环播放
- 后台播放
- 锁屏控制
- 播放进度保存

视频播放：
- 播放/暂停控制
- 进度条拖动
- 全屏播放
- 画面比例调整
- 亮度和音量控制
- 播放速度调节
- 画中画模式（支持的平台）

播放列表：
- 创建播放列表
- 播放列表管理
- 自动播放下一个
- 随机播放

下载管理：
- 离线下载音频/视频
- 下载进度显示
- 下载管理
- 存储空间管理

#### 实体设计

MediaFile实体：
- id：媒体文件ID
- type：类型（audio/video）
- title：标题
- url：在线URL
- localPath：本地路径（已下载）
- duration：时长
- size：文件大小
- thumbnail：缩略图
- isDownloaded：是否已下载
- downloadProgress：下载进度

PlaybackState实体：
- mediaId：媒体ID
- position：播放位置
- duration：总时长
- isPlaying：是否播放中
- playbackSpeed：播放速度
- volume：音量
- isLooping：是否循环

#### 用例设计

PlayMedia Use Case：
- 输入：mediaFile
- 输出：Either<Failure, PlaybackState>
- 业务逻辑：初始化播放器并开始播放

PauseMedia Use Case：
- 输入：无
- 输出：Either<Failure, PlaybackState>
- 业务逻辑：暂停当前播放

SeekTo Use Case：
- 输入：position
- 输出：Either<Failure, PlaybackState>
- 业务逻辑：跳转到指定位置

SetPlaybackSpeed Use Case：
- 输入：speed
- 输出：Either<Failure, PlaybackState>
- 业务逻辑：设置播放速度

DownloadMedia Use Case：
- 输入：mediaFile
- 输出：Either<Failure, DownloadProgress>
- 业务逻辑：下载媒体文件到本地

GetDownloadedMedia Use Case：
- 输入：无
- 输出：Either<Failure, List<MediaFile>>
- 业务逻辑：获取所有已下载的媒体文件

#### 状态设计

AudioPlayerState状态类型：
- AudioPlayerInitial：初始状态
- AudioPlayerLoading：加载中
- AudioPlayerPlaying：播放中
- AudioPlayerPaused：已暂停
- AudioPlayerCompleted：播放完成
- AudioPlayerError：播放错误

VideoPlayerState状态类型：
- VideoPlayerInitial：初始状态
- VideoPlayerLoading：加载中
- VideoPlayerPlaying：播放中
- VideoPlayerPaused：已暂停
- VideoPlayerCompleted：播放完成
- VideoPlayerError：播放错误

#### UI页面设计

音频播放器页面（AudioPlayerPage）：

页面结构：
- 封面图片（居中大图）
- 标题和作者信息
- 播放进度条
- 当前时间/总时长
- 播放控制按钮组
  - 上一首
  - 播放/暂停（大按钮）
  - 下一首
- 底部功能栏
  - 播放速度
  - 循环模式
  - 播放列表
  - 定时关闭

交互逻辑：
- 进度条可拖动
- 点击封面图全屏显示
- 支持手势快进/快退
- 后台播放通知控制
- 锁屏显示播放信息

视频播放器页面（VideoPlayerPage）：

页面结构：
- 视频画面（支持手势）
- 播放控制层（可自动隐藏）
  - 播放/暂停按钮
  - 进度条
  - 时间显示
  - 全屏按钮
- 设置面板（侧滑）
  - 播放速度
  - 画面比例
  - 清晰度选择

交互逻辑：
- 单击显示/隐藏控制层
- 双击播放/暂停
- 左右滑动快进/快退
- 上下滑动调节音量/亮度
- 全屏模式自适应旋转

下载管理页面（DownloadManagerPage）：

页面结构：
- 正在下载列表
- 已下载列表
- 存储空间信息
- 清理缓存按钮

列表项内容：
- 媒体缩略图和标题
- 文件大小
- 下载进度（进行中）
- 操作按钮（暂停/继续/删除）

交互逻辑：
- 下载进度实时更新
- 支持批量删除
- 点击已下载项直接播放
- 下载失败可重试

### 2.6 个人中心模块（Profile Module）

#### 功能概述

展示用户个人信息，管理应用设置，查看练习成就。

#### 核心功能清单

个人信息：
- 头像显示和更换
- 昵称修改
- 邮箱显示
- 注册时间
- 会员信息（如有）

练习成就：
- 练习徽章展示
- 里程碑达成
- 连续打卡记录
- 成就进度

应用设置：
- 主题切换（浅色/深色/跟随系统）
- 语言选择
- 通知设置
- 提醒设置
- 缓存管理
- 关于应用

账号管理：
- 修改密码
- 绑定第三方账号（可选）
- 注销账号
- 退出登录

数据管理：
- 数据导出
- 数据同步设置
- 清除缓存
- 存储空间查看

#### 实体设计

UserProfile实体：
- user：用户基本信息
- avatar：头像URL
- practiceStats：练习统计摘要
- achievements：成就列表
- preferences：用户偏好设置

Achievement实体：
- id：成就ID
- name：成就名称
- description：描述
- icon：图标
- isUnlocked：是否解锁
- unlockedAt：解锁时间
- progress：进度（0-100）
- requirement：达成要求

AppSettings实体：
- theme：主题模式
- language：语言
- notificationsEnabled：是否启用通知
- reminderEnabled：是否启用提醒
- autoSyncEnabled：是否自动同步
- downloadQuality：下载质量

#### 用例设计

GetUserProfile Use Case：
- 输入：userId
- 输出：Either<Failure, UserProfile>
- 业务逻辑：获取用户完整档案

UpdateProfile Use Case：
- 输入：userId, profileUpdates
- 输出：Either<Failure, UserProfile>
- 业务逻辑：更新用户信息

UploadAvatar Use Case：
- 输入：imageFile
- 输出：Either<Failure, String>
- 业务逻辑：上传头像并返回URL

GetAchievements Use Case：
- 输入：userId
- 输出：Either<Failure, List<Achievement>>
- 业务逻辑：获取用户成就列表

UpdateSettings Use Case：
- 输入：settings
- 输出：Either<Failure, AppSettings>
- 业务逻辑：更新应用设置

ChangePassword Use Case：
- 输入：oldPassword, newPassword
- 输出：Either<Failure, Unit>
- 业务逻辑：验证旧密码并更新新密码

ExportUserData Use Case：
- 输入：userId
- 输出：Either<Failure, File>
- 业务逻辑：导出用户所有数据

DeleteAccount Use Case：
- 输入：userId, password
- 输出：Either<Failure, Unit>
- 业务逻辑：验证密码并删除账号

#### 状态设计

ProfileState状态类型：
- ProfileInitial：初始状态
- ProfileLoading：加载中
- ProfileLoaded：已加载（包含用户档案）
- ProfileUpdating：更新中
- ProfileError：错误

SettingsState状态类型：
- SettingsInitial：初始状态
- SettingsLoaded：已加载（包含设置）
- SettingsUpdating：更新中
- SettingsUpdated：更新成功
- SettingsError：错误

#### UI页面设计

个人中心主页（ProfilePage）：

页面结构：
- 顶部个人信息卡片
  - 头像（可点击更换）
  - 昵称和邮箱
  - 编辑按钮
- 练习数据卡片
  - 总练习次数
  - 累计时长
  - 连续天数
  - 查看详情按钮
- 成就区域
  - 最新解锁成就
  - 查看全部按钮
- 功能菜单列表
  - 我的方法库
  - 练习历史
  - 设置
  - 关于
  - 退出登录

交互逻辑：
- 点击头像上传新头像
- 点击编辑跳转编辑页面
- 各功能项跳转对应页面
- 退出登录需要确认

编辑资料页（EditProfilePage）：

页面结构：
- 头像编辑区
- 昵称输入框
- 邮箱显示（不可编辑）
- 个人简介输入框
- 保存按钮

交互逻辑：
- 实时输入验证
- 保存前确认
- 保存成功返回主页

成就页面（AchievementsPage）：

页面结构：
- 顶部进度摘要
- 成就分类标签
- 成就网格展示
  - 已解锁成就（彩色）
  - 未解锁成就（灰色）
  - 进度条显示

成就卡片内容：
- 成就图标
- 成就名称
- 达成描述
- 解锁时间（已解锁）
- 进度显示（未解锁）

交互逻辑：
- 点击查看成就详情
- 分享成就
- 按类别筛选

设置页面（SettingsPage）：

页面结构：
- 外观设置组
  - 主题选择
  - 字体大小
- 通知设置组
  - 启用通知开关
  - 提醒设置
- 数据设置组
  - 自动同步开关
  - 仅WiFi同步
  - 下载质量
- 缓存管理组
  - 缓存大小显示
  - 清除缓存按钮
- 账号设置组
  - 修改密码
  - 注销账号
- 关于组
  - 版本号
  - 隐私政策
  - 用户协议
  - 检查更新

交互逻辑：
- 设置项实时生效
- 清除缓存需要确认
- 注销账号二次确认
- 修改密码跳转新页面

### 2.7 消息通知模块（Notification Module）

#### 功能概述

管理应用内通知和推送通知，提醒用户练习和系统消息。

#### 核心功能清单

练习提醒：
- 定时练习提醒
- 自定义提醒时间
- 提醒内容个性化
- 提醒历史记录

系统通知：
- 应用更新通知
- 新方法推荐通知
- 成就解锁通知
- 系统公告

通知管理：
- 通知中心查看所有通知
- 通知已读/未读状态
- 通知分类展示
- 批量操作（全部已读/清空）

推送权限：
- 推送权限请求
- 推送开关管理
- 免打扰时段设置

#### 实体设计

Notification实体：
- id：通知ID
- type：通知类型（reminder/system/achievement）
- title：标题
- message：消息内容
- data：附加数据
- isRead：是否已读
- createdAt：创建时间
- scheduledAt：计划发送时间

ReminderSettings实体：
- id：设置ID
- methodId：关联方法ID
- enabled：是否启用
- time：提醒时间
- frequency：频率（daily/weekly/custom）
- daysOfWeek：星期几（weekly时使用）
- message：提醒消息

#### 用例设计

GetNotifications Use Case：
- 输入：userId, type, isRead
- 输出：Either<Failure, List<Notification>>
- 业务逻辑：获取通知列表

MarkAsRead Use Case：
- 输入：notificationId
- 输出：Either<Failure, Unit>
- 业务逻辑：标记通知为已读

MarkAllAsRead Use Case：
- 输入：userId
- 输出：Either<Failure, Unit>
- 业务逻辑：标记所有通知为已读

DeleteNotification Use Case：
- 输入：notificationId
- 输出：Either<Failure, Unit>
- 业务逻辑：删除通知

ScheduleReminder Use Case：
- 输入：reminderSettings
- 输出：Either<Failure, Unit>
- 业务逻辑：创建定时提醒

CancelReminder Use Case：
- 输入：reminderId
- 输出：Either<Failure, Unit>
- 业务逻辑：取消提醒

RequestNotificationPermission Use Case：
- 输入：无
- 输出：Either<Failure, bool>
- 业务逻辑：请求推送通知权限

#### 状态设计

NotificationState状态类型：
- NotificationInitial：初始状态
- NotificationLoading：加载中
- NotificationLoaded：已加载（包含通知列表）
- NotificationOperating：操作进行中
- NotificationError：错误

#### UI页面设计

通知中心页面（NotificationCenterPage）：

页面结构：
- 顶部操作栏
  - 全部已读按钮
  - 筛选按钮
- 通知分类标签
- 通知列表

通知列表项：
- 通知图标
- 标题和消息
- 时间
- 未读标记
- 操作按钮

交互逻辑：
- 下拉刷新
- 点击查看详情
- 左滑删除
- 长按批量选择
- 空状态提示

提醒设置页面（ReminderSettingsPage）：

页面结构：
- 主开关
- 提醒列表
  - 方法名称
  - 提醒时间
  - 频率显示
  - 启用开关
- 添加提醒按钮
- 免打扰设置

交互逻辑：
- 添加新提醒
- 编辑提醒
- 删除提醒
- 设置免打扰时段

### 2.8 离线模式模块（Offline Mode Module）

#### 功能概述

支持离线访问已缓存的数据，确保无网络时的基本功能可用。

#### 核心功能清单

离线缓存：
- 方法列表缓存
- 方法详情缓存
- 用户数据缓存
- 媒体文件下载

离线同步：
- 离线操作队列
- 网络恢复时自动同步
- 冲突处理
- 同步进度显示

离线指示：
- 网络状态指示
- 离线模式提示
- 不可用功能禁用
- 同步状态显示

#### 实体设计

CachedData实体：
- key：缓存键
- data：缓存数据
- cachedAt：缓存时间
- expiresAt：过期时间
- version：数据版本

OfflineOperation实体：
- id：操作ID
- type：操作类型（create/update/delete）
- entity：实体类型
- data：操作数据
- createdAt：创建时间
- synced：是否已同步
- syncedAt：同步时间

#### 用例设计

CacheData Use Case：
- 输入：key, data, expiration
- 输出：Either<Failure, Unit>
- 业务逻辑：缓存数据到本地

GetCachedData Use Case：
- 输入：key
- 输出：Either<Failure, Data>
- 业务逻辑：从缓存获取数据

QueueOfflineOperation Use Case：
- 输入：operation
- 输出：Either<Failure, Unit>
- 业务逻辑：将离线操作加入队列

SyncOfflineOperations Use Case：
- 输入：无
- 输出：Either<Failure, SyncResult>
- 业务逻辑：同步所有离线操作

CheckNetworkStatus Use Case：
- 输入：无
- 输出：bool
- 业务逻辑：检查网络连接状态

---

## 三、测试体系设计

### 3.1 单元测试（Unit Tests）

#### 测试范围

需要覆盖所有业务逻辑层的代码。

**Use Cases测试**

每个Use Case需要测试：
- 正常流程测试
- 异常流程测试
- 边界条件测试
- 输入验证测试

测试覆盖目标：
- Use Cases：100%覆盖
- Repository：80%+覆盖
- Utils：90%+覆盖

**Entities测试**

测试内容：
- 实体创建
- 字段验证
- 相等性比较（Equatable）
- 序列化和反序列化

**Utils测试**

测试内容：
- 日期格式化
- 输入验证器
- 字符串处理
- 数据转换

#### 测试结构

每个Use Case测试文件结构：

```
describe: Use Case名称
  group: 成功场景
    test: 应该返回正确的结果
    test: 应该调用Repository的正确方法
  
  group: 失败场景
    test: 应该返回ServerFailure当服务器错误时
    test: 应该返回NetworkFailure当无网络时
  
  group: 边界条件
    test: 应该处理空输入
    test: 应该处理极大值
```

#### 测试工具

使用工具：
- flutter_test：Flutter官方测试框架
- mockito：Mock框架
- faker：测试数据生成

Mock策略：
- Mock所有外部依赖
- 不Mock被测试的对象
- 使用MockSpec注解自动生成Mock

#### 测试命名规范

测试文件命名：
- Use Case：`use_case_name_test.dart`
- Repository：`repository_name_test.dart`
- Entity：`entity_name_test.dart`

测试描述规范：
- 使用"should"开头
- 描述清晰的预期行为
- 包含测试场景

### 3.2 Widget测试（Widget Tests）

#### 测试范围

覆盖所有关键UI组件和页面。

**Pages测试**

每个Page需要测试：
- 初始渲染测试
- 用户交互测试
- 状态变化测试
- 导航测试
- 错误显示测试

测试覆盖目标：
- 核心页面：100%覆盖
- 通用组件：90%+覆盖
- 辅助页面：70%+覆盖

**自定义Widget测试**

测试内容：
- 组件渲染
- Props传递
- 回调触发
- 样式应用
- 响应式布局

**BLoC集成测试**

测试内容：
- BLoC状态响应
- Event触发
- 状态更新UI
- 错误状态显示

#### 测试结构

Page测试文件结构：

```
describe: Page名称
  group: 渲染测试
    test: 应该显示标题
    test: 应该显示所有必要元素
  
  group: 交互测试
    test: 应该响应按钮点击
    test: 应该触发正确的Event
  
  group: 状态测试
    test: Loading状态应该显示进度指示器
    test: Success状态应该显示数据
    test: Error状态应该显示错误消息
```

#### 测试工具

使用工具：
- flutter_test：Widget测试框架
- bloc_test：BLoC测试工具
- golden_toolkit：黄金测试（可选）

测试辅助：
- WidgetTester：Widget测试器
- pumpWidget：渲染Widget
- find：查找Widget元素
- expect：断言

#### 测试最佳实践

Widget包装：
- 使用MaterialApp包装测试Widget
- 提供必要的依赖（BLoC、Theme等）
- 使用MediaQuery提供屏幕信息

异步测试：
- 使用pumpAndSettle等待动画完成
- 使用pump手动推进帧
- 正确处理Future和Stream

查找器使用：
- 优先使用Key查找
- 使用语义标签查找
- 避免使用文本查找（国际化问题）

### 3.3 集成测试（Integration Tests）

#### 测试范围

测试多个模块协作和完整数据流。

**API集成测试**

测试内容：
- API请求和响应
- 数据转换（Model <-> Entity）
- Repository实现
- 错误处理

测试场景：
- 成功的API调用
- 网络错误处理
- 401认证失败
- 超时处理
- 数据解析错误

**数据流集成测试**

测试内容：
- UI -> BLoC -> Use Case -> Repository -> API
- 完整的数据流转
- 状态变化链
- 缓存策略

测试场景：
- 用户登录流程
- 获取方法列表流程
- 记录练习流程
- 离线数据同步

**存储集成测试**

测试内容：
- 本地数据库操作
- 安全存储操作
- SharedPreferences操作
- 缓存读写

测试场景：
- 数据持久化
- 数据恢复
- 缓存过期
- 存储清理

#### 测试结构

集成测试文件结构：

```
describe: 功能模块
  setUpAll: 初始化测试环境
  
  group: API集成
    test: 应该成功调用API并返回数据
    test: 应该处理网络错误
  
  group: 数据流集成
    test: 应该完整执行登录流程
    test: 应该正确更新所有相关状态
  
  tearDownAll: 清理测试环境
```

#### 测试环境

Mock服务器：
- 使用mockito或http_mock
- 模拟真实API响应
- 模拟各种错误场景

测试数据库：
- 使用内存数据库
- 每个测试独立数据
- 测试后清理数据

测试配置：
- 独立的测试环境配置
- 不影响开发环境
- 可重复运行

### 3.4 端到端测试（E2E Tests）

#### 测试范围

测试完整的用户操作流程。

**核心用户流程测试**

测试场景：
1. 新用户注册流程
   - 打开应用
   - 进入注册页面
   - 填写信息并注册
   - 自动登录
   - 进入首页

2. 用户登录流程
   - 打开应用
   - 输入账号密码
   - 登录成功
   - 查看首页内容

3. 浏览和添加方法流程
   - 浏览方法列表
   - 搜索方法
   - 查看方法详情
   - 添加到个人库
   - 查看个人库

4. 记录练习流程
   - 选择方法
   - 开始练习
   - 记录时长和心情
   - 提交记录
   - 查看历史

5. 查看统计流程
   - 进入统计页面
   - 查看图表
   - 切换时间范围
   - 查看详细数据

**异常场景测试**

测试场景：
- 网络中断场景
- 应用后台返回
- 低内存场景
- 权限拒绝场景

#### 测试工具

使用工具：
- integration_test：Flutter官方E2E测试
- flutter_driver：驱动测试（可选）

平台测试：
- Android：使用Android emulator
- iOS：使用iOS simulator
- Web：使用Chrome headless
- Desktop：使用本地环境

#### 测试结构

E2E测试文件结构：

```
describe: 用户流程
  setUpAll: 启动应用和测试环境
  
  test: 新用户注册和首次使用流程
    - 步骤1描述和断言
    - 步骤2描述和断言
    - ...
  
  test: 老用户登录和日常使用流程
    - 步骤1描述和断言
    - 步骤2描述和断言
    - ...
  
  tearDownAll: 清理测试数据
```

#### 测试执行策略

执行频率：
- 每次发布前必须全部通过
- 每日自动执行（CI/CD）
- 重大功能开发后执行

执行环境：
- 使用真实的后端API（测试环境）
- 使用真实设备或模拟器
- 记录测试执行视频

失败处理：
- 截图保存失败场景
- 记录详细日志
- 自动重试不稳定的测试

### 3.5 性能测试（Performance Tests）

#### 测试范围

应用启动性能：
- 冷启动时间
- 热启动时间
- 首屏渲染时间

UI性能：
- 列表滚动帧率
- 页面切换流畅度
- 动画性能
- 内存占用

网络性能：
- API请求响应时间
- 图片加载时间
- 视频缓冲时间

#### 性能指标

启动性能目标：
- 冷启动：< 3秒
- 热启动：< 1秒
- 首屏渲染：< 2秒

UI性能目标：
- 列表滚动：60 FPS
- 页面切换：< 300ms
- 动画流畅：60 FPS
- 内存占用：< 200MB

网络性能目标：
- API请求：< 1秒（正常网络）
- 图片加载：< 2秒
- 视频缓冲：< 3秒

#### 性能测试工具

Flutter性能工具：
- Flutter DevTools
- Performance Overlay
- Timeline View
- Memory Profiler

测试方法：
- 使用Profile模式测试
- 在真实设备上测试
- 测试不同性能的设备
- 测试不同网络条件

### 3.6 测试覆盖率目标

#### 覆盖率要求

代码覆盖率目标：
- 整体覆盖率：≥ 80%
- Domain层：≥ 95%
- Data层：≥ 85%
- Presentation层：≥ 75%

功能覆盖率目标：
- 核心功能：100%
- 重要功能：90%
- 辅助功能：70%

#### 覆盖率工具

使用工具：
- flutter test --coverage
- lcov
- genhtml

报告生成：
- 生成HTML报告
- 查看未覆盖代码
- 持续跟踪覆盖率

#### 覆盖率提升策略

优先级：
1. 先覆盖核心业务逻辑
2. 再覆盖API交互
3. 最后覆盖UI层

改进措施：
- 定期review覆盖率报告
- 新功能要求带测试
- 重构时补充测试
- CI/CD检查覆盖率

---

## 四、跨平台适配设计

### 4.1 Android平台适配

#### 最低版本要求

目标版本：
- minSdkVersion：21（Android 5.0）
- targetSdkVersion：33（Android 13）
- compileSdkVersion：33

兼容性考虑：
- 支持Android 5.0+覆盖95%+用户
- 使用androidx库
- Material Design 3组件

#### 平台特性适配

通知功能：
- 使用flutter_local_notifications
- 支持通知渠道（Android 8.0+）
- 通知权限请求（Android 13+）
- 通知样式自定义

文件访问：
- Scoped Storage适配（Android 10+）
- 文件权限请求
- MediaStore API使用
- 文件选择器

后台任务：
- WorkManager使用
- 后台限制适配
- 电池优化处理
- 前台服务

#### UI适配

Material Design适配：
- 使用Material组件
- 主题颜色适配
- 导航栏适配
- 状态栏适配

屏幕适配：
- 不同分辨率适配
- 不同DPI适配
- 横屏布局适配
- 刘海屏适配

#### 性能优化

启动优化：
- SplashScreen优化
- 减少启动时间
- 预加载关键资源

内存优化：
- 图片内存控制
- 列表回收优化
- 及时释放资源

包体积优化：
- 使用App Bundle
- 启用代码混淆
- 移除未使用资源
- 图片压缩

#### 权限管理

必需权限：
- INTERNET：网络访问
- ACCESS_NETWORK_STATE：网络状态

可选权限：
- CAMERA：拍照上传头像
- READ_MEDIA_IMAGES：读取图片（Android 13+）
- POST_NOTIFICATIONS：推送通知（Android 13+）
- WRITE_EXTERNAL_STORAGE：文件存储（Android <10）

权限请求策略：
- 运行时请求
- 说明权限用途
- 优雅降级

#### 签名和发布

签名配置：
- 生成keystore
- 配置签名信息
- 保护keystore安全

构建配置：
- Release构建
- 代码混淆
- 资源压缩
- 多渠道打包（可选）

### 4.2 iOS平台适配

#### 最低版本要求

目标版本：
- Deployment Target：12.0
- 支持iOS 12+覆盖95%+用户
- 使用Swift 5.0+

兼容性考虑：
- UIKit和SwiftUI混合使用
- 向后兼容API
- 优雅降级不支持的功能

#### 平台特性适配

通知功能：
- UserNotifications框架
- 通知权限请求
- 通知内容扩展
- 推送证书配置

文件访问：
- 文档目录访问
- 照片库访问
- 文件权限请求
- iCloud同步（可选）

后台任务：
- Background Modes配置
- 后台音频播放
- 后台刷新
- 后台下载

#### UI适配

Cupertino适配：
- 使用Cupertino组件
- iOS风格导航
- 手势交互
- 系统字体

屏幕适配：
- Safe Area处理
- 不同尺寸适配
- 刘海屏适配
- iPad布局

暗黑模式：
- 自动适配系统主题
- 颜色自适应
- 图标适配

#### 性能优化

启动优化：
- LaunchScreen优化
- 预编译优化
- 资源按需加载

内存优化：
- ARC内存管理
- 图片缓存优化
- 及时释放资源

包体积优化：
- Bitcode优化
- 资源切片
- 移除未使用资源

#### 权限管理

Info.plist权限声明：
- NSCameraUsageDescription：相机权限
- NSPhotoLibraryUsageDescription：照片库权限
- NSMicrophoneUsageDescription：麦克风权限
- NSUserNotificationsUsageDescription：通知权限

权限请求策略：
- 首次使用时请求
- 清晰说明用途
- 提供跳转设置选项

#### 签名和发布

证书配置：
- Development证书
- Distribution证书
- Provisioning Profile

构建配置：
- Release构建
- Bitcode启用
- 符号表上传
- TestFlight测试

### 4.3 Web平台适配

#### 技术要求

浏览器支持：
- Chrome 90+
- Safari 14+
- Firefox 88+
- Edge 90+

技术选型：
- CanvasKit渲染
- PWA支持
- Service Worker

#### 平台特性适配

路由管理：
- 使用URL路由
- 浏览器前进后退
- 深链接支持
- 路由参数传递

存储方案：
- IndexedDB存储
- LocalStorage备用
- Cookie管理
- 跨域处理

文件处理：
- File API使用
- 拖拽上传
- 下载功能
- 预览功能

#### UI适配

响应式设计：
- 移动端布局
- 桌面端布局
- 平板布局
- 断点设置

交互适配：
- 鼠标交互
- 键盘快捷键
- 右键菜单
- 滚动优化

性能优化：
- 代码分割
- 懒加载
- 缓存策略
- CDN加速

#### PWA支持

Manifest配置：
- 应用名称和图标
- 启动URL
- 显示模式
- 主题颜色

Service Worker：
- 离线缓存
- 后台同步
- 推送通知
- 更新策略

#### 部署配置

构建配置：
- Web构建
- 资源优化
- 压缩配置
- 环境变量

服务器配置：
- HTTPS配置
- CORS配置
- 缓存策略
- 路由重写

### 4.4 Windows平台适配

#### 技术要求

系统版本：
- Windows 10 1809+
- Windows 11

技术依赖：
- Visual C++ Redistributable
- Windows SDK

#### 平台特性适配

窗口管理：
- 窗口大小和位置
- 最小化和最大化
- 窗口置顶
- 系统托盘

文件系统：
- 文件对话框
- 拖拽文件
- 文件关联
- 默认存储位置

系统集成：
- 开始菜单快捷方式
- 桌面快捷方式
- 开机自启动（可选）
- 系统通知

#### UI适配

Windows UI规范：
- 标题栏自定义
- 右键菜单
- 系统字体
- Fluent Design元素

窗口布局：
- 最小窗口尺寸
- 响应式布局
- 多显示器支持
- 高DPI适配

#### 性能优化

启动优化：
- 快速启动
- 后台启动选项
- 资源预加载

内存优化：
- 内存占用控制
- 资源释放
- 缓存管理

#### 打包和分发

安装包制作：
- MSIX安装包
- 传统安装程序
- 便携版本

应用商店发布：
- Microsoft Store准备
- 应用截图和描述
- 审核要求

### 4.5 macOS平台适配

#### 技术要求

系统版本：
- macOS 10.14+（Mojave）
- macOS 11+（Big Sur）
- macOS 12+（Monterey）

技术依赖：
- Xcode 13+
- CocoaPods

#### 平台特性适配

窗口管理：
- 原生窗口标题栏
- 全屏模式
- 多窗口支持
- Mission Control

文件系统：
- 文件对话框
- 拖拽支持
- Finder集成
- iCloud Drive

系统集成：
- 菜单栏应用
- Dock图标
- Touch Bar支持
- 系统通知

#### UI适配

macOS UI规范：
- 原生外观
- 系统字体（SF Pro）
- 系统颜色
- 暗黑模式

窗口布局：
- 窗口大小限制
- 自适应布局
- Retina适配
- 分屏支持

#### 性能优化

启动优化：
- 快速启动
- 预加载优化
- 延迟初始化

内存优化：
- 内存压缩
- 缓存策略
- 资源释放

#### 签名和公证

代码签名：
- Developer ID签名
- 证书配置
- Entitlements配置

公证流程：
- Notarization
- Stapling
- Gatekeeper兼容

#### 打包和分发

App Bundle：
- DMG镜像
- PKG安装包
- 签名和公证

Mac App Store：
- Sandbox配置
- 应用审核
- 元数据准备

### 4.6 跨平台统一设计

#### 条件编译策略

平台判断：
- 使用Platform.isAndroid
- 使用Platform.isIOS
- 使用kIsWeb
- 使用Platform.isWindows/isMacOS

平台特定代码组织：
```
lib/
├── platform/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   └── macos/
└── platform_interface/
```

#### 统一抽象接口

平台服务抽象：
- 文件服务接口
- 通知服务接口
- 分享服务接口
- 存储服务接口

实现策略：
- 定义通用接口
- 各平台实现
- 工厂模式选择实现
- 运行时注入

#### 响应式设计

断点设置：
- 手机：< 600px
- 平板：600px - 1024px
- 桌面：> 1024px

布局适配：
- 单栏布局（手机）
- 双栏布局（平板）
- 多栏布局（桌面）
- 自适应导航

#### 输入方式适配

触摸交互：
- 手势识别
- 触摸反馈
- 滑动操作

鼠标交互：
- 悬停效果
- 右键菜单
- 拖拽操作

键盘交互：
- 快捷键
- Tab导航
- 焦点管理

---

## 五、应用商店发布设计

### 5.1 Google Play发布

#### 发布准备

开发者账号：
- 注册Google Play开发者账号
- 支付注册费用（$25一次性）
- 完善开发者信息

App签名：
- 生成上传密钥
- 配置Play App Signing
- 保管好keystore文件

#### 应用元数据

基本信息：
- 应用名称（最多30字符）
- 简短描述（最多80字符）
- 完整描述（最多4000字符）
- 应用类别选择

视觉资源：
- 应用图标（512x512px）
- 功能图片（1024x500px）
- 手机截图（至少2张）
- 平板截图（可选）
- 宣传视频（可选）

联系信息：
- 开发者邮箱
- 隐私政策URL
- 支持网站URL

#### 内容分级

分级问卷：
- 完成IARC问卷
- 获取内容分级
- 各国分级显示

目标受众：
- 目标年龄组
- 是否针对儿童
- 广告声明

#### 定价和分发

定价策略：
- 免费应用
- 应用内购买（可选）
- 订阅服务（可选）

分发国家：
- 选择发布国家/地区
- 设置各地区定价
- 分阶段发布（可选）

#### 测试发布

Internal Testing：
- 内部测试轨道
- 快速测试和迭代
- 不限测试人数

Closed Testing：
- 封闭测试轨道
- 指定测试用户
- 收集反馈

Open Testing：
- 公开测试
- 任何人可参与
- 正式发布前验证

#### 正式发布

发布流程：
- 创建发布版本
- 上传AAB文件
- 填写版本说明
- 提交审核

审核时间：
- 通常1-3天
- 首次发布可能更长
- 审核通过自动上架

#### 发布后管理

更新管理：
- 版本更新
- 问题修复
- 功能迭代

用户反馈：
- 查看评分和评论
- 及时回复用户
- 收集改进建议

数据分析：
- 下载量统计
- 用户留存率
- 崩溃报告
- 性能指标

### 5.2 Apple App Store发布

#### 发布准备

开发者账号：
- 注册Apple Developer账号
- 支付年费（$99/年）
- 完善账号信息

App ID创建：
- 创建Bundle ID
- 配置Capabilities
- 配置App Groups（如需）

证书配置：
- Distribution证书
- Provisioning Profile
- 推送证书（如需）

#### App Store Connect配置

应用信息：
- 应用名称（最多30字符）
- 副标题（最多30字符）
- 描述（最多4000字符）
- 关键词（最多100字符）
- 应用类别

视觉资源：
- 应用图标（1024x1024px）
- 截图（各设备尺寸）
  - iPhone 6.7"：1290x2796px
  - iPhone 6.5"：1284x2778px
  - iPhone 5.5"：1242x2208px
  - iPad Pro 12.9"：2048x2732px
- 预览视频（可选）

联系信息：
- 支持URL
- 营销URL（可选）
- 隐私政策URL

#### 内容分级

Age Rating：
- 完成年龄分级问卷
- 选择合适的年龄等级
- 声明内容类型

隐私信息：
- 数据收集声明
- 数据使用说明
- 第三方数据共享

#### 定价和可用性

定价设置：
- 选择定价层级
- 各国定价配置
- 应用内购买设置

可用性：
- 发布国家/地区
- 发布日期设置
- 预订选项（可选）

#### TestFlight测试

内部测试：
- 添加内部测试员
- 快速构建测试
- 无需审核

外部测试：
- 创建测试组
- 添加外部测试员
- 需要Beta审核
- 收集反馈

#### 正式提交

构建上传：
- 使用Xcode上传
- 或使用Application Loader
- 等待构建处理

审核信息：
- 测试账号信息
- 演示视频（如需）
- 审核备注

提交审核：
- 选择构建版本
- 填写版本信息
- 提交审核

#### 审核过程

审核时间：
- 通常1-3天
- 复杂应用可能更长
- 节假日可能延迟

审核状态：
- Waiting for Review：等待审核
- In Review：审核中
- Pending Developer Release：待发布
- Ready for Sale：已上架
- Rejected：被拒绝

被拒处理：
- 查看拒绝原因
- 修复问题
- 重新提交
- 或申诉

#### 发布后管理

版本更新：
- 创建新版本
- 上传新构建
- 填写更新内容
- 提交审核

用户反馈：
- 查看评分和评论
- 回复用户评论
- 收集改进建议

数据分析：
- App Analytics查看数据
- 下载量统计
- 用户留存
- 崩溃报告

### 5.3 Web部署

#### 部署准备

域名和服务器：
- 注册域名
- 选择托管服务
- 配置DNS

SSL证书：
- 申请SSL证书
- 配置HTTPS
- 强制HTTPS跳转

#### 构建配置

Flutter Web构建：
```bash
flutter build web --release
```

构建优化：
- 启用代码压缩
- 资源优化
- 生成Source Map

环境变量：
- 配置生产环境API地址
- 配置CDN地址
- 配置分析代码

#### 服务器配置

Nginx配置示例：
```nginx
server {
    listen 443 ssl http2;
    server_name app.example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    root /var/www/flutter_app;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 缓存静态资源
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

#### CDN配置

CDN服务选择：
- Cloudflare
- AWS CloudFront
- 阿里云CDN

CDN配置：
- 静态资源CDN加速
- 缓存策略配置
- 回源配置

#### PWA配置

Manifest配置：
```json
{
  "name": "心理自助应用",
  "short_name": "Nian",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

Service Worker：
- 配置缓存策略
- 离线支持
- 后台同步

#### 部署流程

自动化部署：
- 配置CI/CD
- Git push触发构建
- 自动部署到服务器

部署脚本示例：
```bash
#!/bin/bash

# 构建
flutter build web --release

# 上传到服务器
rsync -avz --delete build/web/ user@server:/var/www/flutter_app/

# 重启服务
ssh user@server 'sudo systemctl reload nginx'
```

#### 监控和分析

性能监控：
- Google Analytics
- 自定义埋点
- 错误监控

访问统计：
- 访问量统计
- 用户行为分析
- 转化率跟踪

### 5.4 Windows应用商店发布

#### 发布准备

开发者账号：
- 注册Microsoft Partner Center账号
- 支付注册费用（个人$19，公司$99）
- 完善开发者信息

MSIX打包：
- 配置应用标识
- 生成MSIX包
- 应用签名

#### 应用提交

Partner Center配置：
- 创建应用提交
- 填写应用信息
- 上传MSIX包
- 配置定价

应用元数据：
- 应用名称
- 描述（最多10000字符）
- 截图（至少1张）
- 应用图标
- 类别选择

年龄分级：
- 完成分级问卷
- 声明内容类型
- 获取分级

#### 审核发布

提交审核：
- 提交应用
- 等待认证
- 自动测试

审核时间：
- 通常1-3天
- 复杂应用可能更长

发布选项：
- 立即发布
- 定时发布
- 手动发布

### 5.5 macOS App Store发布

#### 发布准备

同iOS准备：
- 使用同一开发者账号
- 创建macOS App ID
- 配置证书和Profile

Sandbox配置：
- 启用App Sandbox
- 配置Entitlements
- 网络权限
- 文件访问权限

#### App Store Connect配置

macOS应用信息：
- 应用名称
- 描述
- 关键词
- 类别

macOS截图：
- 至少1张截图
- 支持各种分辨率
- 展示核心功能

#### 提交和审核

构建上传：
- 使用Xcode上传
- 等待构建处理
- 选择构建版本

审核流程：
- 同iOS审核流程
- 审核标准类似
- 通过后上架

---

## 六、实施计划

### 6.1 开发阶段划分

#### 第一阶段：基础架构（2周）

目标：建立完整的项目架构和基础设施

任务清单：
- 完善项目结构和配置
- 实现依赖注入框架
- 实现基础网络层（Dio + Retrofit）
- 实现本地存储层（SQLite + Secure Storage）
- 实现错误处理框架
- 实现日志系统
- 实现路由管理
- 建立基础UI组件库

交付物：
- 完整的项目骨架
- 网络和存储基础设施
- 公共组件库
- 单元测试（核心工具类）

#### 第二阶段：认证模块（1周）

目标：实现完整的用户认证功能

任务清单：
- 实现User Entity和Model
- 实现Auth Repository
- 实现认证相关Use Cases
- 实现Auth BLoC
- 实现登录页面
- 实现注册页面
- 实现启动页面
- 实现Token管理

交付物：
- 认证模块完整代码
- 单元测试（Use Cases和Repository）
- Widget测试（登录和注册页面）
- 集成测试（认证流程）

#### 第三阶段：方法浏览模块（2周）

目标：实现方法浏览和搜索功能

任务清单：
- 实现Method和Category Entity
- 实现Method Repository
- 实现方法相关Use Cases
- 实现Method List BLoC
- 实现Method Detail BLoC
- 实现Method Search BLoC
- 实现方法列表页面
- 实现方法详情页面
- 实现搜索页面
- 实现筛选功能

交付物：
- 方法浏览模块完整代码
- 单元测试
- Widget测试
- 集成测试

#### 第四阶段：个人方法库模块（1.5周）

目标：实现个人方法库管理

任务清单：
- 实现UserMethod Entity
- 实现UserMethod Repository
- 实现用户方法相关Use Cases
- 实现UserMethod BLoC
- 实现个人方法库页面
- 实现方法详情页面
- 实现添加方法功能

交付物：
- 个人方法库模块完整代码
- 单元测试
- Widget测试
- 集成测试

#### 第五阶段：练习记录模块（2周）

目标：实现练习记录和统计分析

任务清单：
- 实现PracticeRecord Entity
- 实现Practice Repository
- 实现练习相关Use Cases
- 实现Practice BLoC
- 实现练习记录页面
- 实现练习历史页面
- 实现练习统计页面
- 实现图表可视化

交付物：
- 练习记录模块完整代码
- 单元测试
- Widget测试
- 集成测试

#### 第六阶段：多媒体和个人中心（1.5周）

目标：实现多媒体播放和个人中心

任务清单：
- 实现音频播放器
- 实现视频播放器
- 实现下载管理
- 实现个人中心页面
- 实现设置页面
- 实现成就系统

交付物：
- 多媒体和个人中心模块代码
- 单元测试
- Widget测试
- 集成测试

#### 第七阶段：跨平台适配（2周）

目标：完成所有平台的适配和优化

任务清单：
- Android平台适配和优化
- iOS平台适配和优化
- Web平台适配和优化
- Windows平台适配和优化
- macOS平台适配和优化
- 响应式布局优化
- 性能优化

交付物：
- 五个平台可运行的应用
- 平台特定功能测试
- 性能测试报告

#### 第八阶段：测试和修复（1周）

目标：完善测试覆盖率并修复问题

任务清单：
- 补充单元测试达到目标覆盖率
- 补充Widget测试
- 执行端到端测试
- 性能测试
- 修复发现的问题
- 代码审查和优化

交付物：
- 完整的测试报告
- 覆盖率报告
- 问题修复清单
- 优化后的代码

#### 第九阶段：发布准备（1周）

目标：准备应用商店发布材料

任务清单：
- 准备应用截图和宣传图
- 撰写应用描述
- 配置应用商店信息
- 生成发布版本
- 准备测试账号
- 编写发布文档

交付物：
- 各平台发布包
- 应用商店元数据
- 发布文档
- 测试账号信息

### 6.2 人员配置建议

推荐团队配置：
- Flutter开发工程师：2人
- UI/UX设计师：1人
- 测试工程师：1人
- 项目经理：1人（兼职）

职责分工：

Flutter工程师A：
- 负责核心业务模块开发
- 负责状态管理实现
- 负责单元测试

Flutter工程师B：
- 负责UI页面开发
- 负责跨平台适配
- 负责Widget测试

UI/UX设计师：
- 负责界面设计
- 负责交互设计
- 负责视觉资源准备

测试工程师：
- 负责测试用例编写
- 负责集成测试和E2E测试
- 负责问题跟踪

项目经理：
- 负责进度管理
- 负责需求确认
- 负责协调沟通

### 6.3 里程碑和交付节点

#### 里程碑1：基础架构完成（第2周末）

验收标准：
- 项目架构搭建完成
- 网络和存储层可用
- 基础组件库建立
- 单元测试框架就绪

#### 里程碑2：核心功能完成（第6周末）

验收标准：
- 认证、方法浏览、方法库模块完成
- 基本功能可用
- 单元测试覆盖率达标
- Widget测试完成

#### 里程碑3：完整功能开发完成（第9周末）

验收标准：
- 所有功能模块完成
- 多媒体功能可用
- 个人中心完成
- 集成测试通过

#### 里程碑4：跨平台适配完成（第11周末）

验收标准：
- 五个平台全部适配
- 平台特性功能正常
- 性能达到目标
- E2E测试通过

#### 里程碑5：发布就绪（第13周末）

验收标准：
- 所有测试通过
- 覆盖率达标
- 发布包生成
- 文档齐全

### 6.4 风险管理

#### 技术风险

风险1：跨平台兼容性问题
- 概率：中
- 影响：中
- 应对措施：
  - 提前在各平台测试
  - 预留适配时间
  - 准备平台特定解决方案

风险2：性能不达标
- 概率：中
- 影响：高
- 应对措施：
  - 持续性能监控
  - 及时优化
  - 使用性能最佳实践

风险3：第三方库兼容性
- 概率：低
- 影响：中
- 应对措施：
  - 选择成熟稳定的库
  - 验证多平台兼容性
  - 准备备选方案

#### 进度风险

风险1：需求变更
- 概率：中
- 影响：高
- 应对措施：
  - 需求冻结原则
  - 变更控制流程
  - 预留缓冲时间

风险2：人员变动
- 概率：低
- 影响：高
- 应对措施：
  - 代码文档化
  - 知识分享机制
  - 备份人员计划

风险3：测试不充分
- 概率：中
- 影响：高
- 应对措施：
  - 测试驱动开发
  - 自动化测试
  - 专职测试人员

#### 质量风险

风险1：代码质量问题
- 概率：低
- 影响：中
- 应对措施：
  - 代码审查
  - 代码规范
  - 静态分析工具

风险2：用户体验问题
- 概率：中
- 影响：高
- 应对措施：
  - 用户测试
  - 设计评审
  - 迭代优化

---

## 七、文档交付清单

### 7.1 开发文档

#### 技术设计文档

架构设计文档：
- 系统架构图
- 模块划分
- 技术选型说明
- 数据流设计

API对接文档：
- API接口清单
- 请求响应格式
- 错误码说明
- 认证机制

数据库设计文档：
- 本地数据库表结构
- 数据关系图
- 索引设计
- 缓存策略

#### 编码规范文档

Dart编码规范：
- 命名规范
- 代码格式
- 注释规范
- 最佳实践

Flutter开发规范：
- Widget规范
- 状态管理规范
- 性能优化规范
- 测试规范

### 7.2 测试文档

#### 测试计划文档

测试策略：
- 测试范围
- 测试方法
- 测试工具
- 测试环境

测试用例文档：
- 功能测试用例
- 性能测试用例
- 兼容性测试用例
- 安全测试用例

#### 测试报告文档

单元测试报告：
- 测试覆盖率
- 测试结果统计
- 失败用例分析

Widget测试报告：
- 测试覆盖的组件
- 测试结果
- 问题清单

集成测试报告：
- 测试场景
- 测试结果
- 性能数据

E2E测试报告：
- 测试流程
- 测试结果
- 用户体验评估

性能测试报告：
- 性能指标数据
- 瓶颈分析
- 优化建议

### 7.3 部署文档

#### 平台部署指南

Android部署文档：
- 环境准备
- 签名配置
- 构建步骤
- Google Play发布流程
- 常见问题解决

iOS部署文档：
- 环境准备
- 证书配置
- 构建步骤
- App Store发布流程
- TestFlight使用指南

Web部署文档：
- 服务器配置
- 构建和部署步骤
- CDN配置
- SSL证书配置
- 域名配置

Windows部署文档：
- 环境准备
- MSIX打包
- 签名配置
- Microsoft Store发布

macOS部署文档：
- 环境准备
- 签名和公证
- App Store发布
- DMG制作

#### CI/CD配置文档

GitHub Actions配置：
- 自动构建流程
- 自动测试流程
- 自动部署流程

其他CI工具配置：
- GitLab CI
- Jenkins
- Bitrise

### 7.4 用户文档

#### 用户手册

快速开始指南：
- 注册和登录
- 基本功能介绍
- 常用操作说明

功能使用指南：
- 浏览方法
- 添加方法到个人库
- 记录练习
- 查看统计
- 个人设置

#### FAQ文档

常见问题解答：
- 账号相关问题
- 功能使用问题
- 技术问题
- 隐私和安全问题

故障排除指南：
- 登录问题
- 同步问题
- 性能问题
- 崩溃问题

### 7.5 运维文档

#### 监控和告警文档

监控指标：
- 应用性能指标
- 错误率监控
- 用户行为监控

告警配置：
- 告警规则
- 告警渠道
- 应急响应流程

#### 维护手册

日常维护：
- 数据备份
- 日志管理
- 版本更新

应急处理：
- 紧急问题处理流程
- 回滚操作
- 数据恢复

---

## 八、质量保证措施

### 8.1 代码质量保证

#### 代码审查机制

审查流程：
- 所有代码必须经过审查
- 至少一人审查通过方可合并
- 使用Pull Request机制

审查要点：
- 代码规范遵守
- 逻辑正确性
- 性能考虑
- 安全性
- 测试覆盖
- 文档完整性

审查工具：
- GitHub Pull Request
- GitLab Merge Request
- Gerrit

#### 静态代码分析

分析工具：
- Dart Analyzer
- Flutter Lints
- 自定义Lint规则

检查项目：
- 语法错误
- 潜在bug
- 代码异味
- 性能问题
- 安全漏洞

CI集成：
- 自动运行分析
- 失败阻止合并
- 生成报告

### 8.2 测试质量保证

#### 测试覆盖率要求

最低覆盖率：
- 整体代码覆盖率：≥80%
- Domain层：≥95%
- Data层：≥85%
- Presentation层：≥75%

覆盖率监控：
- 每次提交检查覆盖率
- 覆盖率下降阻止合并
- 定期review覆盖率报告

#### 测试质量标准

测试有效性：
- 测试用例有意义
- 断言正确
- 避免无效测试

测试独立性：
- 测试之间无依赖
- 可独立运行
- 可并行执行

测试可维护性：
- 清晰的测试描述
- 合理的测试结构
- 易于修改和扩展

### 8.3 性能质量保证

#### 性能基准测试

建立基准：
- 初始版本性能数据
- 作为后续对比基准
- 定期更新基准

持续监控：
- 每次构建测试性能
- 性能退化及时发现
- 性能改进记录

#### 性能优化检查表

启动性能：
- [ ] 减少启动时初始化
- [ ] 延迟加载非关键资源
- [ ] 优化首屏渲染

UI性能：
- [ ] 使用const构造函数
- [ ] 列表懒加载
- [ ] 避免不必要的重建
- [ ] 优化复杂布局

网络性能：
- [ ] 请求合并
- [ ] 响应缓存
- [ ] 图片压缩
- [ ] 分页加载

内存性能：
- [ ] 及时释放资源
- [ ] 图片内存控制
- [ ] 避免内存泄漏
- [ ] 合理使用缓存

### 8.4 安全质量保证

#### 安全代码审查

审查重点：
- 敏感数据处理
- 输入验证
- 认证授权
- 数据传输
- 第三方库安全

常见问题检查：
- SQL注入
- XSS攻击
- CSRF攻击
- 中间人攻击
- 敏感信息泄露

#### 安全测试

渗透测试：
- 认证绕过测试
- 授权测试
- 数据篡改测试
- 注入攻击测试

依赖安全扫描：
- 使用安全扫描工具
- 检查已知漏洞
- 及时更新依赖

### 8.5 用户体验质量保证

#### 可用性测试

测试方法：
- 用户访谈
- A/B测试
- 热力图分析
- 用户录屏分析

测试指标：
- 任务完成率
- 任务完成时间
- 错误率
- 满意度

#### 可访问性测试

测试内容：
- 屏幕阅读器支持
- 颜色对比度
- 文本可读性
- 键盘导航
- 手势替代方案

测试工具：
- Flutter accessibility tools
- 平台可访问性检查工具
- 手动测试

---

## 九、项目成功标准

### 9.1 功能完整性标准

核心功能：
- [ ] 用户注册和登录正常
- [ ] 方法浏览和搜索可用
- [ ] 方法详情完整展示
- [ ] 个人方法库管理正常
- [ ] 练习记录功能完整
- [ ] 统计分析数据准确
- [ ] 多媒体播放流畅
- [ ] 个人中心功能完整

辅助功能：
- [ ] 通知提醒正常
- [ ] 离线模式可用
- [ ] 设置功能完整
- [ ] 数据同步正常

### 9.2 质量标准

代码质量：
- [ ] 测试覆盖率≥80%
- [ ] 所有测试用例通过
- [ ] 无严重代码规范问题
- [ ] 无已知严重bug

性能标准：
- [ ] 冷启动时间<3秒
- [ ] 列表滚动60FPS
- [ ] API响应<1秒
- [ ] 内存占用<200MB

稳定性标准：
- [ ] 崩溃率<0.1%
- [ ] ANR率<0.05%
- [ ] 网络错误处理完善
- [ ] 异常情况可恢复

### 9.3 用户体验标准

UI设计：
- [ ] 界面美观一致
- [ ] 交互流畅自然
- [ ] 反馈及时清晰
- [ ] 适配各种屏幕

易用性：
- [ ] 学习成本低
- [ ] 操作简单直观
- [ ] 错误提示友好
- [ ] 帮助文档完善

可访问性：
- [ ] 支持屏幕阅读器
- [ ] 颜色对比度达标
- [ ] 支持键盘导航
- [ ] 文本可缩放

### 9.4 发布就绪标准

技术就绪：
- [ ] 所有平台构建成功
- [ ] 发布版本签名配置
- [ ] 性能优化完成
- [ ] 安全检查通过

商店就绪：
- [ ] 应用元数据准备完整
- [ ] 截图和宣传图准备
- [ ] 隐私政策和用户协议
- [ ] 测试账号准备

文档就绪：
- [ ] 开发文档完整
- [ ] 测试文档完整
- [ ] 部署文档完整
- [ ] 用户文档完整

---

## 十、后续维护计划

### 10.1 版本迭代计划

#### 版本1.1（发布后1个月）

主要内容：
- 修复用户反馈的问题
- 性能优化
- 小功能改进

#### 版本1.2（发布后3个月）

主要内容：
- 新增社区功能
- 新增分享功能
- 新增数据导出
- UI优化

#### 版本2.0（发布后6个月）

主要内容：
- AI智能推荐优化
- 社交功能扩展
- 专业版功能
- 主题定制

### 10.2 运维支持计划

日常监控：
- 应用性能监控
- 错误日志监控
- 用户反馈收集
- 数据统计分析

定期维护：
- 每周检查崩溃报告
- 每月性能评估
- 每季度安全审计
- 依赖库更新

应急响应：
- 严重bug 24小时内修复
- 紧急问题热更新机制
- 回滚预案
- 用户通知机制

### 10.3 持续改进计划

用户反馈：
- 建立反馈渠道
- 定期整理分析
- 优先级排序
- 纳入开发计划

技术债务：
- 记录技术债务
- 定期评估
- 安排偿还时间
- 防止累积

技术升级：
- 关注Flutter版本更新
- 评估升级价值
- 计划升级时间
- 测试兼容性

---

## 附录：关键技术决策说明

### A.1 架构选择：Clean Architecture

选择理由：
- 清晰的层次划分
- 业务逻辑独立
- 易于测试
- 易于维护和扩展
- 适合中大型项目

替代方案：
- MVVM：相对简单，但层次不够清晰
- MVC：过于传统，不适合Flutter

### A.2 状态管理：BLoC模式

选择理由：
- Flutter官方推荐
- 状态管理清晰
- 易于测试
- 社区成熟
- 适合复杂应用

替代方案：
- Provider：简单但功能有限
- Riverpod：较新，社区较小
- GetX：功能多但耦合度高

### A.3 依赖注入：GetIt + Injectable

选择理由：
- 简单易用
- 代码生成减少手写
- 性能好
- 社区支持

替代方案：
- get_it alone：需要手写更多代码
- Provider：不够灵活
- Riverpod：学习曲线陡峭

### A.4 网络请求：Dio + Retrofit

选择理由：
- 功能强大
- 拦截器支持
- 代码生成
- 类型安全
- 社区成熟

替代方案：
- http package：功能简单
- Chopper：类似但社区较小

### A.5 本地存储：SQLite + Secure Storage

选择理由：
- SQLite适合结构化数据
- Secure Storage保护敏感信息
- 性能好
- 跨平台支持好

替代方案：
- Hive：更快但功能有限
- Isar：较新，生态不成熟
- Shared Preferences：仅适合简单数据

### A.6 路由管理：GoRouter

选择理由：
- 声明式路由
- Deep linking支持
- 类型安全
- 适合Web
- Flutter官方推荐

替代方案：
- Navigator 1.0：传统但不够灵活
- Auto Route：代码生成但较重
- Fluro：较老，功能有限- 拖拽文件
-