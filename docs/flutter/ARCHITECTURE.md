# Flutter应用架构设计

## 架构概述

采用 Clean Architecture + BLoC 模式，支持 Android、iOS、Web、macOS、Windows 五平台。

## 技术栈

| 类别 | 技术选型 |
|------|---------|
| 框架 | Flutter 3.0+, Dart 3.0+ |
| 状态管理 | flutter_bloc |
| 网络请求 | Dio |
| 本地存储 | flutter_secure_storage, shared_preferences, sqflite |
| 函数式编程 | dartz (Either模式) |

## 分层架构

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │  <- Widgets + BLoC
├─────────────────────────────────────┤
│     Domain Layer (Business Logic)   │  <- Entities + Repository接口
├─────────────────────────────────────┤
│     Data Layer (Data Access)        │  <- Repository实现 + DataSource
└─────────────────────────────────────┘
```

### Presentation Layer（表现层）
- **Pages**: 完整页面（login_page.dart）
- **Widgets**: 可复用组件（loading_indicator.dart）
- **BLoC**: 状态管理（auth_bloc.dart）

### Domain Layer（领域层）
- **Entities**: 业务实体（user.dart, method.dart）
- **Repositories**: 接口定义（auth_repository.dart）

### Data Layer（数据层）
- **Models**: JSON序列化模型（user_model.dart）
- **Repositories**: 接口实现（auth_repository_impl.dart）
- **DataSources**: 数据源（auth_remote_data_source.dart）

## 目录结构

```
lib/
├── config/              # 配置（API、路由、主题）
├── core/                # 核心功能
│   ├── di/             # 依赖注入
│   ├── error/          # 错误处理
│   ├── network/        # 网络客户端
│   ├── storage/        # 本地存储
│   └── utils/          # 工具类
├── data/                # 数据层
│   ├── api/            # API客户端
│   ├── datasources/    # 数据源
│   ├── models/         # 数据模型
│   └── repositories/   # Repository实现
├── domain/              # 领域层
│   ├── entities/       # 业务实体
│   └── repositories/   # Repository接口
└── presentation/        # 表现层
    ├── auth/           # 认证模块
    ├── home/           # 首页
    ├── methods/        # 方法模块
    ├── practice/       # 练习模块
    ├── profile/        # 个人中心
    ├── user_methods/   # 个人方法库
    └── widgets/        # 共享组件
```

## 数据流

```
UI (Widget)
  ↓ 触发事件
BLoC
  ↓ 调用Repository
Repository
  ↓ 请求DataSource
DataSource (API/Database)
  ↓ 返回Model
Repository (转换为Entity)
  ↓ 返回 Either<Failure, Entity>
BLoC (更新State)
  ↓ 通知UI
Widget 重建
```

## 错误处理

使用 Either<Failure, Data> 模式统一处理：

```dart
// Repository返回
Future<Either<Failure, User>> login(email, password);

// BLoC处理
result.fold(
  (failure) => emit(AuthFailure(failure.message)),
  (user) => emit(AuthSuccess(user)),
);
```

## 核心模块

### 认证模块
- 登录/注册/自动登录
- JWT Token安全存储
- 401自动登出

### 方法模块
- 方法列表/详情
- 分类筛选/搜索
- 添加到个人库

### 练习模块
- 记录练习
- 历史查询
- 统计分析

### 个人中心
- 主题切换
- 通知设置
- 隐私政策

## 构建命令

```bash
# 开发
flutter run -d windows
flutter run -d chrome
flutter run -d android

# 发布
flutter build apk --release
flutter build windows --release
flutter build web --release
```

---
**版本**: 1.1.0 | **更新**: 2026-01-06
