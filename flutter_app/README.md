# 心理自助应用 - Flutter 客户端

全平台心理自助应用的移动端实现，支持 iOS、Android、macOS 和 Windows。

## 功能特性

- 🔐 用户认证（注册、登录）
- 📱 心理方法浏览和搜索
- ⭐ 个性化方法推荐
- 📝 练习记录追踪
- 📊 练习统计分析
- 🎨 Material Design + Cupertino 风格
- 🌓 深色模式支持
- 💾 安全存储（Token 加密）

## 技术栈

- **框架**: Flutter 3.0+
- **状态管理**: BLoC Pattern (flutter_bloc)
- **网络请求**: Dio + Retrofit
- **本地存储**: flutter_secure_storage, shared_preferences
- **路由**: Navigator 2.0
- **架构**: Clean Architecture + Repository Pattern

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/                      # 配置文件
│   │   ├── theme.dart              # 主题配置
│   │   ├── routes.dart             # 路由配置
│   │   └── api_constants.dart      # API常量
│   ├── data/                        # 数据层
│   │   ├── api/                    # API客户端
│   │   │   └── api_client.dart
│   │   ├── models/                 # 数据模型
│   │   │   ├── user.dart
│   │   │   ├── method.dart
│   │   │   └── practice.dart
│   │   ├── repositories/           # 仓库层
│   │   │   ├── auth_repository.dart
│   │   │   ├── method_repository.dart
│   │   │   └── practice_repository.dart
│   │   └── storage/                # 本地存储
│   │       └── secure_storage.dart
│   ├── blocs/                       # BLoC状态管理
│   │   ├── auth/                   # 认证BLoC
│   │   ├── method/                 # 方法BLoC
│   │   └── practice/               # 练习BLoC
│   ├── screens/                     # 页面
│   │   ├── splash_screen.dart      # 启动页
│   │   ├── auth/                   # 认证页面
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/                   # 首页
│   │   │   └── home_screen.dart
│   │   ├── method/                 # 方法页面
│   │   │   ├── method_list_screen.dart
│   │   │   └── method_detail_screen.dart
│   │   ├── practice/               # 练习页面
│   │   │   └── practice_screen.dart
│   │   └── profile/                # 个人中心
│   │       └── profile_screen.dart
│   ├── widgets/                     # 通用组件
│   │   ├── method_card.dart
│   │   ├── practice_chart.dart
│   │   └── loading_indicator.dart
│   └── utils/                       # 工具类
│       ├── validators.dart
│       └── date_formatter.dart
├── assets/                          # 资源文件
│   ├── images/
│   └── icons/
├── test/                            # 测试文件
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 项目说明
```

## 核心模块说明

### 1. 配置模块 (config/)

- **theme.dart**: Material Design 主题配置，支持浅色和深色模式
- **routes.dart**: 应用路由配置，定义所有页面路径
- **api_constants.dart**: API端点和常量定义

### 2. 数据层 (data/)

#### API客户端
- 使用 Dio 进行网络请求
- 自动添加 JWT Token
- 统一错误处理
- 请求/响应拦截器

#### 数据模型
```dart
// 用户模型
class User {
  final int id;
  final String email;
  final String nickname;
  // ...
}

// 方法模型
class Method {
  final int id;
  final String title;
  final String category;
  final String difficulty;
  final int duration;
  final Map<String, dynamic> contentJson;
  // ...
}

// 练习记录模型
class Practice {
  final int id;
  final int methodId;
  final int userId;
  final int durationMinutes;
  final int moodBefore;
  final int moodAfter;
  // ...
}
```

#### 仓库层
- **AuthRepository**: 用户认证相关（登录、注册、获取用户信息）
- **MethodRepository**: 方法管理（列表、详情、搜索、推荐）
- **PracticeRepository**: 练习记录（创建、查询、统计）

### 3. 状态管理 (blocs/)

使用 BLoC 模式进行状态管理：

```dart
// 认证状态
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}

// 认证事件
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;
}
class LogoutRequested extends AuthEvent {}
```

### 4. 页面 (screens/)

#### 启动页 (SplashScreen)
- 检查登录状态
- 自动跳转到主页或登录页

#### 认证页面
- **LoginScreen**: 用户登录
- **RegisterScreen**: 用户注册
- 表单验证
- 错误提示

#### 主页 (HomeScreen)
- 推荐方法展示
- 快速访问常用功能
- 练习统计概览

#### 方法页面
- **MethodListScreen**: 方法列表，支持筛选和搜索
- **MethodDetailScreen**: 方法详情，包含步骤说明和使用提示

#### 练习页面 (PracticeScreen)
- 记录练习过程
- 评分心理状态
- 查看练习历史

#### 个人中心 (ProfileScreen)
- 用户信息展示
- 练习统计数据
- 设置选项

## 开发环境设置

### 前置要求

- Flutter SDK 3.0.0 或更高版本
- Dart 3.0.0 或更高版本
- iOS: Xcode 14+
- Android: Android Studio / Android SDK
- macOS: Xcode 14+
- Windows: Visual Studio 2022

### 安装依赖

```bash
cd flutter_app
flutter pub get
```

### 运行应用

#### iOS
```bash
flutter run -d ios
```

#### Android
```bash
flutter run -d android
```

#### macOS
```bash
flutter run -d macos
```

#### Windows
```bash
flutter run -d windows
```

### 构建发布版本

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

## API 配置

默认 API 地址为 `http://localhost:3000/api`。

可以通过环境变量修改：

```bash
flutter run --dart-define=API_URL=https://your-api-url.com/api
```

## 代码生成

项目使用代码生成工具生成序列化代码：

```bash
# 生成代码
flutter pub run build_runner build

# 监听模式（开发时使用）
flutter pub run build_runner watch

# 删除冲突
flutter pub run build_runner build --delete-conflicting-outputs
```

## 测试

```bash
# 运行所有测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 依赖说明

### 核心依赖
- `flutter_bloc` - BLoC 状态管理
- `equatable` - 值对象比较
- `dio` - HTTP 客户端
- `retrofit` - REST API 封装
- `json_annotation` - JSON 序列化

### 存储
- `shared_preferences` - 简单键值存储
- `flutter_secure_storage` - 安全存储（Token）

### 工具
- `intl` - 国际化和日期格式化
- `logger` - 日志工具

### 开发依赖
- `flutter_lints` - 代码规范
- `build_runner` - 代码生成
- `retrofit_generator` - Retrofit 代码生成
- `json_serializable` - JSON 序列化代码生成

## 项目状态

### 已完成
✅ 项目结构搭建
✅ 配置文件设置
✅ API 客户端封装
✅ 安全存储实现
✅ 主题配置
✅ 路由配置

### 待实现
⏳ 数据模型定义
⏳ Repository 层实现
⏳ BLoC 状态管理实现
⏳ UI 页面开发
⏳ 单元测试
⏳ 集成测试

## 注意事项

1. **安全性**: 
   - Token 使用 flutter_secure_storage 加密存储
   - 所有 API 请求自动携带 JWT Token
   - 401 错误自动清除登录状态

2. **性能优化**:
   - 使用 const 构造函数减少重建
   - 列表使用 ListView.builder 懒加载
   - 图片缓存和优化

3. **跨平台适配**:
   - iOS 使用 Cupertino 风格组件
   - Android 使用 Material Design 组件
   - 根据平台自动选择合适的UI风格

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

MIT License
# 心理自助应用 - Flutter 客户端

全平台心理自助应用的移动端实现，支持 iOS、Android、macOS 和 Windows。

## 功能特性

- 🔐 用户认证（注册、登录）
- 📱 心理方法浏览和搜索
- ⭐ 个性化方法推荐
- 📝 练习记录追踪
- 📊 练习统计分析
- 🎨 Material Design + Cupertino 风格
- 🌓 深色模式支持
- 💾 安全存储（Token 加密）

## 技术栈

- **框架**: Flutter 3.0+
- **状态管理**: BLoC Pattern (flutter_bloc)
- **网络请求**: Dio + Retrofit
- **本地存储**: flutter_secure_storage, shared_preferences
- **路由**: Navigator 2.0
- **架构**: Clean Architecture + Repository Pattern

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/                      # 配置文件
│   │   ├── theme.dart              # 主题配置
│   │   ├── routes.dart             # 路由配置
│   │   └── api_constants.dart      # API常量
│   ├── data/                        # 数据层
│   │   ├── api/                    # API客户端
│   │   │   └── api_client.dart
│   │   ├── models/                 # 数据模型
│   │   │   ├── user.dart
│   │   │   ├── method.dart
│   │   │   └── practice.dart
│   │   ├── repositories/           # 仓库层
│   │   │   ├── auth_repository.dart
│   │   │   ├── method_repository.dart
│   │   │   └── practice_repository.dart
│   │   └── storage/                # 本地存储
│   │       └── secure_storage.dart
│   ├── blocs/                       # BLoC状态管理
│   │   ├── auth/                   # 认证BLoC
│   │   ├── method/                 # 方法BLoC
│   │   └── practice/               # 练习BLoC
│   ├── screens/                     # 页面
│   │   ├── splash_screen.dart      # 启动页
│   │   ├── auth/                   # 认证页面
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/                   # 首页
│   │   │   └── home_screen.dart
│   │   ├── method/                 # 方法页面
│   │   │   ├── method_list_screen.dart
│   │   │   └── method_detail_screen.dart
│   │   ├── practice/               # 练习页面
│   │   │   └── practice_screen.dart
│   │   └── profile/                # 个人中心
│   │       └── profile_screen.dart
│   ├── widgets/                     # 通用组件
│   │   ├── method_card.dart
│   │   ├── practice_chart.dart
│   │   └── loading_indicator.dart
│   └── utils/                       # 工具类
│       ├── validators.dart
│       └── date_formatter.dart
├── assets/                          # 资源文件
│   ├── images/
│   └── icons/
├── test/                            # 测试文件
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 项目说明
```

## 核心模块说明

### 1. 配置模块 (config/)

- **theme.dart**: Material Design 主题配置，支持浅色和深色模式
- **routes.dart**: 应用路由配置，定义所有页面路径
- **api_constants.dart**: API端点和常量定义

### 2. 数据层 (data/)

#### API客户端
- 使用 Dio 进行网络请求
- 自动添加 JWT Token
- 统一错误处理
- 请求/响应拦截器

#### 数据模型
```dart
// 用户模型
class User {
  final int id;
  final String email;
  final String nickname;
  // ...
}

// 方法模型
class Method {
  final int id;
  final String title;
  final String category;
  final String difficulty;
  final int duration;
  final Map<String, dynamic> contentJson;
  // ...
}

// 练习记录模型
class Practice {
  final int id;
  final int methodId;
  final int userId;
  final int durationMinutes;
  final int moodBefore;
  final int moodAfter;
  // ...
}
```

#### 仓库层
- **AuthRepository**: 用户认证相关（登录、注册、获取用户信息）
- **MethodRepository**: 方法管理（列表、详情、搜索、推荐）
- **PracticeRepository**: 练习记录（创建、查询、统计）

### 3. 状态管理 (blocs/)

使用 BLoC 模式进行状态管理：

```dart
// 认证状态
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}

// 认证事件
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;
}
class LogoutRequested extends AuthEvent {}
```

### 4. 页面 (screens/)

#### 启动页 (SplashScreen)
- 检查登录状态
- 自动跳转到主页或登录页

#### 认证页面
- **LoginScreen**: 用户登录
- **RegisterScreen**: 用户注册
- 表单验证
- 错误提示

#### 主页 (HomeScreen)
- 推荐方法展示
- 快速访问常用功能
- 练习统计概览

#### 方法页面
- **MethodListScreen**: 方法列表，支持筛选和搜索
- **MethodDetailScreen**: 方法详情，包含步骤说明和使用提示

#### 练习页面 (PracticeScreen)
- 记录练习过程
- 评分心理状态
- 查看练习历史

#### 个人中心 (ProfileScreen)
- 用户信息展示
- 练习统计数据
- 设置选项

## 开发环境设置

### 前置要求

- Flutter SDK 3.0.0 或更高版本
- Dart 3.0.0 或更高版本
- iOS: Xcode 14+
- Android: Android Studio / Android SDK
- macOS: Xcode 14+
- Windows: Visual Studio 2022

### 安装依赖

```bash
cd flutter_app
flutter pub get
```

### 运行应用

#### iOS
```bash
flutter run -d ios
```

#### Android
```bash
flutter run -d android
```

#### macOS
```bash
flutter run -d macos
```

#### Windows
```bash
flutter run -d windows
```

### 构建发布版本

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

## API 配置

默认 API 地址为 `http://localhost:3000/api`。

可以通过环境变量修改：

```bash
flutter run --dart-define=API_URL=https://your-api-url.com/api
```

## 代码生成

项目使用代码生成工具生成序列化代码：

```bash
# 生成代码
flutter pub run build_runner build

# 监听模式（开发时使用）
flutter pub run build_runner watch

# 删除冲突
flutter pub run build_runner build --delete-conflicting-outputs
```

## 测试

```bash
# 运行所有测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 依赖说明

### 核心依赖
- `flutter_bloc` - BLoC 状态管理
- `equatable` - 值对象比较
- `dio` - HTTP 客户端
- `retrofit` - REST API 封装
- `json_annotation` - JSON 序列化

### 存储
- `shared_preferences` - 简单键值存储
- `flutter_secure_storage` - 安全存储（Token）

### 工具
- `intl` - 国际化和日期格式化
- `logger` - 日志工具

### 开发依赖
- `flutter_lints` - 代码规范
- `build_runner` - 代码生成
- `retrofit_generator` - Retrofit 代码生成
- `json_serializable` - JSON 序列化代码生成

## 项目状态

### 已完成
✅ 项目结构搭建
✅ 配置文件设置
✅ API 客户端封装
✅ 安全存储实现
✅ 主题配置
✅ 路由配置

### 待实现
⏳ 数据模型定义
⏳ Repository 层实现
⏳ BLoC 状态管理实现
⏳ UI 页面开发
⏳ 单元测试
⏳ 集成测试

## 注意事项

1. **安全性**: 
   - Token 使用 flutter_secure_storage 加密存储
   - 所有 API 请求自动携带 JWT Token
   - 401 错误自动清除登录状态

2. **性能优化**:
   - 使用 const 构造函数减少重建
   - 列表使用 ListView.builder 懒加载
   - 图片缓存和优化

3. **跨平台适配**:
   - iOS 使用 Cupertino 风格组件
   - Android 使用 Material Design 组件
   - 根据平台自动选择合适的UI风格

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

MIT License
