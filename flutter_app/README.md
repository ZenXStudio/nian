# 心理自助应用 - Flutter 客户端

全平台心理自助应用的移动端实现，支持 Android、iOS、Web、macOS 和 Windows。

## 项目状态

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Completion](https://img.shields.io/badge/完成度-95%25-success.svg)

**已完成**: 12个功能页面，约7,700行Dart代码

## 功能特性

### 已完成 ✅
- ✅ 用户认证（注册、登录、自动登录）
- ✅ JWT Token 安全管理
- ✅ 心理方法浏览和搜索
- ✅ 方法详情查看
- ✅ 个性化方法库管理（添加、收藏、目标设置）
- ✅ 练习记录与追踪
- ✅ 练习统计与趋势分析
- ✅ 个人中心（主题、通知、隐私政策）
- ✅ Material Design 风格
- ✅ 深色模式支持

### 待完成 ⏳
- ⏳ App图标替换
- ⏳ 真机测试
- ⏳ 应用商店发布

## 技术栈

- **框架**: Flutter 3.0+
- **状态管理**: BLoC Pattern (flutter_bloc)
- **网络请求**: Dio
- **本地存储**: flutter_secure_storage, shared_preferences, sqflite
- **架构**: Clean Architecture + Repository Pattern
- **函数式编程**: dartz (Either模式)

## 快速开始

### 前置要求

- Flutter SDK 3.0.0+
- Dart 3.0.0+
- 后端 API 服务（默认 http://localhost:3000/api）
- **Windows用户**: 需开启开发者模式

### Windows 开发者模式

```powershell
# 打开设置
start ms-settings:developers
# 开启"开发者模式"开关
```

### 安装步骤

```bash
# 1. 进入目录
cd flutter_app

# 2. 安装依赖
flutter pub get

# 3. 添加平台支持（如需要）
flutter create --platforms=windows .
flutter create --platforms=android .

# 4. 运行应用
flutter run -d windows   # Windows
flutter run -d chrome    # Web
flutter run              # Android（连接设备后）
```

### 配置 API 地址

编辑 `lib/config/api_constants.dart`：

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
}
```

## 项目架构

```
lib/
├── config/                    # 配置文件
│   ├── api_constants.dart    # API配置
│   ├── routes.dart           # 路由配置
│   └── theme.dart            # 主题配置
├── core/                      # 核心功能
│   ├── di/                   # 依赖注入
│   ├── error/                # 错误处理
│   ├── network/              # 网络客户端
│   ├── storage/              # 本地存储
│   └── utils/                # 工具类
├── data/                      # 数据层
│   ├── api/                  # API客户端
│   ├── datasources/          # 数据源
│   ├── models/               # 数据模型
│   └── repositories/         # Repository实现
├── domain/                    # 领域层
│   ├── entities/             # 业务实体
│   └── repositories/         # Repository接口
└── presentation/              # 表现层（12个功能页面）
    ├── auth/                 # 认证模块
    │   ├── bloc/            # 状态管理
    │   └── pages/           # 登录、注册、启动页
    ├── home/                 # 主页框架
    ├── methods/              # 方法模块
    │   ├── bloc/            # 方法列表/搜索BLoC
    │   └── pages/           # 发现、详情、搜索页
    ├── practice/             # 练习模块
    │   ├── bloc/            # 练习BLoC
    │   └── pages/           # 历史、统计页
    ├── profile/              # 个人中心
    │   ├── bloc/            # ProfileBLoC
    │   └── pages/           # 个人中心页
    ├── user_methods/         # 个人方法库
    │   ├── bloc/            # 用户方法BLoC
    │   └── pages/           # 方法库页
    └── widgets/              # 共享组件
```

## 功能页面清单

| 页面 | 文件 | 功能 |
|-----|------|------|
| 启动页 | `splash_page.dart` | 自动登录检测 |
| 登录页 | `login_page.dart` | 邮箱密码登录 |
| 注册页 | `register_page.dart` | 新用户注册 |
| 主页框架 | `main_page.dart` | 底部导航 |
| 方法发现 | `method_discover_page.dart` | 首页内容、分类筛选 |
| 方法详情 | `method_detail_page.dart` | 方法详情、添加到库 |
| 方法搜索 | `method_search_page.dart` | 关键词搜索 |
| 个人方法库 | `user_method_list_page.dart` | 收藏管理、目标设置 |
| 练习历史 | `practice_history_page.dart` | 历史记录、筛选 |
| 练习统计 | `practice_stats_page.dart` | 统计图表 |
| 个人中心 | `profile_page.dart` | 设置、主题、隐私政策 |

## 构建发布

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows
flutter build windows --release

# macOS（需Mac）
flutter build macos --release

# iOS（需Mac）
flutter build ios --release
```

## 常见问题

### Q: Windows构建失败提示需要符号链接支持？
A: 开启Windows开发者模式：`start ms-settings:developers`

### Q: 如何修改API地址？
A: 编辑 `lib/config/api_constants.dart` 中的 `baseUrl`

### Q: 登录后Token存储在哪里？
A: 使用 `flutter_secure_storage` 加密存储在设备安全区域

### Q: 编译时报重复类错误？
A: 运行 `flutter clean` 后重新 `flutter pub get`

## 许可证

MIT License
