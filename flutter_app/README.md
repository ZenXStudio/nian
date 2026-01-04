# 心理自助应用 - Flutter 客户端

全平台心理自助应用的移动端实现，支持 Android、iOS、Web、macOS 和 Windows。

## 功能特性

- ✅ 用户认证（注册、登录、自动登录）
- ✅ JWT Token 安全管理
- ✅ Material Design 风格
- ✅ 深色模式支持
- ⏳ 心理方法浏览和搜索（架构已就绪）
- ⏳ 个性化方法库管理（架构已就绪）
- ⏳ 练习记录与追踪（架构已就绪）
- ⏳ 练习统计与趋势分析（架构已就绪）

## 技术栈

- **框架**: Flutter 3.0+
- **状态管理**: BLoC Pattern (flutter_bloc)
- **网络请求**: Dio
- **本地存储**: flutter_secure_storage, shared_preferences, sqflite
- **架构**: Clean Architecture + Repository Pattern
- **函数式编程**: dartz (Either模式)

## 项目架构

项目采用 Clean Architecture 分层架构：

```
lib/
├── domain/                    # 领域层（业务逻辑）
│   ├── entities/             # 业务实体
│   └── repositories/         # Repository接口
├── data/                      # 数据层（数据访问）
│   ├── models/               # 数据模型（JSON序列化）
│   ├── repositories/         # Repository实现
│   └── datasources/          # 数据源（远程API、本地数据库）
├── presentation/              # 表现层（UI）
│   ├── auth/                 # 认证模块
│   │   ├── bloc/            # 状态管理
│   │   └── pages/           # 页面
│   ├── home/                 # 首页
│   ├── methods/              # 方法模块
│   ├── practice/             # 练习模块
│   └── widgets/              # 共享组件
├── core/                      # 核心功能
│   ├── error/                # 错误处理
│   ├── network/              # 网络客户端
│   ├── storage/              # 本地存储
│   └── utils/                # 工具类
└── config/                    # 配置文件
```

## 快速开始

### 前置要求

- Flutter SDK 3.0.0+
- Dart 3.0.0+
- 后端 API 服务（默认 http://localhost:3000/api）

### 安装步骤

1. **克隆仓库**

```bash
cd flutter_app
```

2. **安装依赖**

```bash
flutter pub get
```

3. **配置 API 地址**

编辑 `lib/config/api_constants.dart`：

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';  // 修改为你的API地址
}
```

4. **运行应用**

```bash
# Android
flutter run -d android

# iOS (仅macOS)
flutter run -d ios

# Web
flutter run -d chrome

# macOS桌面
flutter run -d macos

# Windows桌面
flutter run -d windows
```

## 核心功能说明

### 1. 认证模块

- **登录**: 用户邮箱+密码登录
- **注册**: 新用户注册
- **自动登录**: 基于JWT Token的持久化登录
- **安全存储**: Token加密存储

### 2. 数据流架构

```
UI (Widget) → BLoC → Use Case → Repository → Data Source → API/Database
          ← State ← Either<Failure, Data> ←          ←            ←
```

### 3. 错误处理

使用 Either<Failure, Data> 模式统一处理错误：

- **NetworkFailure**: 网络连接错误
- **ServerFailure**: 服务器错误
- **AuthenticationFailure**: 认证失败
- **ValidationFailure**: 输入验证失败

## 开发指南

### 代码规范

- 文件名：`snake_case`
- 类名：`PascalCase`
- 变量/方法：`camelCase`
- 使用 `const` 构造函数优化性能
- 遵循 `flutter_lints` 规范

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle (推荐)
flutter build appbundle --release

# iOS (仅macOS)
flutter build ios --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

## 项目状态

### 已完成 ✅

- Clean Architecture 架构搭建
- 领域层实体（User、Method、PracticeRecord、PracticeStats）
- 数据层模型与Repository实现
- 认证BLoC与状态管理
- 认证页面（Splash、Login、Register）
- 首页框架
- 基础UI组件
- 核心工具类（网络客户端、错误处理、安全存储）

### 进行中 🚧

- 方法浏览功能（数据层已完成，UI待开发）
- 个人方法库（数据层已完成，UI待开发）
- 练习记录功能（数据层已完成，UI待开发）

### 待开发 ⏳

- 个人中心页面
- 练习统计图表
- 单元测试
- 集成测试
- 多语言支持

## API集成

应用需要配合后端API使用，主要API端点：

- `POST /auth/login` - 用户登录
- `POST /auth/register` - 用户注册
- `GET /auth/me` - 获取当前用户信息
- `GET /methods` - 获取方法列表
- `GET /methods/:id` - 获取方法详情
- `POST /practices` - 记录练习
- `GET /practices` - 获取练习历史
- `GET /practices/stats` - 获取练习统计

## 依赖说明

### 核心依赖

- `flutter_bloc: ^8.1.3` - BLoC状态管理
- `equatable: ^2.0.5` - 对象相等性比较
- `dio: ^5.4.0` - HTTP客户端
- `dartz: ^0.10.1` - 函数式编程（Either模式）

### 存储

- `flutter_secure_storage: ^9.0.0` - Token加密存储
- `shared_preferences: ^2.2.2` - 用户偏好存储
- `sqflite: ^2.3.2` - 本地数据库

### 工具

- `intl: ^0.18.1` - 国际化
- `logger: ^2.0.2` - 日志工具

## 注意事项

1. **安全性**
   - Token使用flutter_secure_storage加密存储
   - 所有API请求自动携带JWT Token
   - 401错误自动清除登录状态

2. **性能优化**
   - 使用const构造函数减少重建
   - ListView.builder懒加载
   - 图片缓存

3. **跨平台适配**
   - Material Design适配Android
   - 自动适应不同平台UI风格

## 常见问题

### Q: 如何修改API地址？
A: 编辑 `lib/config/api_constants.dart` 文件中的 `baseUrl` 常量。

### Q: 登录后Token存储在哪里？
A: Token使用 `flutter_secure_storage` 加密存储在设备的安全区域。

### Q: 如何清除缓存？
A: 卸载应用或使用设备的应用设置清除应用数据。

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

MIT License
