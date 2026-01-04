# Flutter应用架构设计文档

## 概述

本文档详细描述了Nian心理自助应用Flutter客户端的架构设计、技术选型和实现方案。该应用将支持Android、iOS、Web、macOS和Windows五个平台。

## 技术栈

### 核心框架
- **Flutter**：3.16+
- **Dart**：3.2+

### 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_bloc: ^8.1.3          # BLoC状态管理
  equatable: ^2.0.5             # 对象相等性比较
  
  # 依赖注入
  get_it: ^7.6.4                # 服务定位器
  injectable: ^2.3.2            # 依赖注入代码生成
  
  # 网络请求
  dio: ^5.4.0                   # HTTP客户端
  retrofit: ^4.0.3              # 类型安全的API客户端
  connectivity_plus: ^5.0.2     # 网络连接检测
  
  # 本地存储
  shared_preferences: ^2.2.2    # 键值对存储
  sqflite: ^2.3.2               # SQLite数据库
  flutter_secure_storage: ^9.0.0 # 安全存储
  
  # 路由管理
  go_router: ^12.1.3            # 声明式路由
  
  # UI组件
  cached_network_image: ^3.3.0  # 图片缓存
  flutter_svg: ^2.0.9           # SVG支持
  shimmer: ^3.0.0               # 骨架屏效果
  flutter_spinkit: ^5.2.0       # 加载动画
  
  # 多媒体
  just_audio: ^0.9.36           # 音频播放
  video_player: ^2.8.1          # 视频播放
  
  # 图表
  fl_chart: ^0.66.0             # 数据图表
  
  # 工具
  intl: ^0.18.0                 # 国际化
  logger: ^2.0.2                # 日志工具
  dartz: ^0.10.1                # 函数式编程
  freezed_annotation: ^2.4.1    # 不可变对象
  json_annotation: ^4.8.1       # JSON序列化

dev_dependencies:
  # 测试
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4               # Mock工具
  bloc_test: ^9.1.5             # BLoC测试
  
  # 代码生成
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  retrofit_generator: ^8.0.6
  
  # 代码检查
  flutter_lints: ^3.0.1
```

## 架构设计

### Clean Architecture

应用采用Clean Architecture（清洁架构）分层设计，确保代码的可维护性、可测试性和可扩展性。

```
┌──────────────────────────────────────────┐
│                                          │
│          Presentation Layer              │
│                                          │
│  ┌────────────┐      ┌────────────┐     │
│  │  Widgets   │◄─────┤   BLoC     │     │
│  └────────────┘      └─────▲──────┘     │
│                             │            │
└─────────────────────────────┼────────────┘
                              │
┌─────────────────────────────┼────────────┐
│                             │            │
│           Domain Layer      │            │
│                             │            │
│  ┌────────────┐      ┌─────┴──────┐     │
│  │  Entities  │      │  Use Cases │     │
│  └────────────┘      └─────▲──────┘     │
│                             │            │
│  ┌──────────────────────────┴─────┐     │
│  │    Repository Interface        │     │
│  └────────────────────────────────┘     │
│                                          │
└─────────────────────────────────────────┘
                              ▲
┌─────────────────────────────┼────────────┐
│                             │            │
│            Data Layer       │            │
│                             │            │
│  ┌──────────────────────────┴─────┐     │
│  │   Repository Implementation    │     │
│  └─────────────┬──────────────────┘     │
│                │                         │
│  ┌─────────────▼──────────┐             │
│  │  Remote Data Source    │             │
│  │  (API Client)          │             │
│  └────────────────────────┘             │
│                                          │
│  ┌────────────────────────┐             │
│  │  Local Data Source     │             │
│  │  (Database/Cache)      │             │
│  └────────────────────────┘             │
│                                          │
└──────────────────────────────────────────┘
```

### 层级职责

#### Presentation Layer（表现层）

**职责**：
- 展示UI
- 处理用户交互
- 响应状态变化

**组件**：
- **Pages**：完整页面
- **Widgets**：可复用的UI组件
- **BLoC/Cubit**：业务逻辑组件，管理状态

**规则**：
- 不包含业务逻辑
- 只依赖Domain层
- 通过BLoC与Domain层通信

#### Domain Layer（领域层）

**职责**：
- 定义业务实体
- 实现业务逻辑
- 定义Repository接口

**组件**：
- **Entities**：业务实体（纯Dart对象）
- **Use Cases**：用例（单一业务操作）
- **Repository Interfaces**：数据访问接口

**规则**：
- 不依赖任何外部框架
- 不依赖其他层
- 最稳定的层

#### Data Layer（数据层）

**职责**：
- 实现数据访问
- 处理数据转换
- 管理缓存策略

**组件**：
- **Repository Implementations**：Repository接口实现
- **Data Sources**：数据源（Remote/Local）
- **Models**：数据模型（带JSON序列化）

**规则**：
- 实现Domain层定义的接口
- 处理数据的获取和转换
- 负责错误处理

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                           # 应用入口
│   ├── app.dart                            # App根组件
│   │
│   ├── config/                             # 配置
│   │   ├── api_constants.dart              # API常量
│   │   ├── app_config.dart                 # 应用配置
│   │   ├── routes.dart                     # 路由配置
│   │   └── theme/                          # 主题
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── core/                               # 核心功能
│   │   ├── error/                          # 错误处理
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/                        # 网络层
│   │   │   ├── dio_client.dart
│   │   │   └── network_info.dart
│   │   ├── utils/                          # 工具类
│   │   │   ├── date_formatter.dart
│   │   │   ├── validators.dart
│   │   │   ├── logger.dart
│   │   │   └── extensions.dart
│   │   └── constants/                      # 常量
│   │       ├── app_constants.dart
│   │       └── storage_keys.dart
│   │
│   ├── data/                               # 数据层
│   │   ├── models/                         # 数据模型
│   │   │   ├── user_model.dart
│   │   │   ├── method_model.dart
│   │   │   ├── practice_model.dart
│   │   │   └── category_model.dart
│   │   ├── repositories/                   # Repository实现
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── method_repository_impl.dart
│   │   │   ├── user_method_repository_impl.dart
│   │   │   └── practice_repository_impl.dart
│   │   └── datasources/                    # 数据源
│   │       ├── local/                      # 本地数据源
│   │       │   ├── app_database.dart
│   │       │   ├── secure_storage.dart
│   │       │   └── shared_prefs.dart
│   │       └── remote/                     # 远程数据源
│   │           ├── auth_api.dart
│   │           ├── method_api.dart
│   │           ├── user_method_api.dart
│   │           └── practice_api.dart
│   │
│   ├── domain/                             # 领域层
│   │   ├── entities/                       # 业务实体
│   │   │   ├── user.dart
│   │   │   ├── method.dart
│   │   │   ├── user_method.dart
│   │   │   ├── practice_record.dart
│   │   │   └── category.dart
│   │   ├── repositories/                   # Repository接口
│   │   │   ├── auth_repository.dart
│   │   │   ├── method_repository.dart
│   │   │   ├── user_method_repository.dart
│   │   │   └── practice_repository.dart
│   │   └── usecases/                       # 用例
│   │       ├── auth/
│   │       │   ├── login.dart
│   │       │   ├── register.dart
│   │       │   ├── logout.dart
│   │       │   └── get_current_user.dart
│   │       ├── methods/
│   │       │   ├── get_methods.dart
│   │       │   ├── get_method_detail.dart
│   │       │   ├── search_methods.dart
│   │       │   └── get_method_by_category.dart
│   │       ├── user_methods/
│   │       │   ├── add_method_to_library.dart
│   │       │   ├── get_user_methods.dart
│   │       │   ├── update_user_method.dart
│   │       │   └── remove_user_method.dart
│   │       └── practices/
│   │           ├── record_practice.dart
│   │           ├── get_practice_history.dart
│   │           ├── get_practice_stats.dart
│   │           └── get_mood_trend.dart
│   │
│   ├── presentation/                       # 表现层
│   │   ├── auth/                           # 认证模块
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── forgot_password_page.dart
│   │   │   └── widgets/
│   │   │       ├── auth_form_field.dart
│   │   │       ├── password_field.dart
│   │   │       └── auth_button.dart
│   │   │
│   │   ├── home/                           # 首页模块
│   │   │   ├── bloc/
│   │   │   │   ├── home_bloc.dart
│   │   │   │   ├── home_event.dart
│   │   │   │   └── home_state.dart
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── category_chip.dart
│   │   │       ├── featured_method_card.dart
│   │   │       └── quick_stats.dart
│   │   │
│   │   ├── methods/                        # 方法浏览模块
│   │   │   ├── bloc/
│   │   │   │   ├── method_list_bloc.dart
│   │   │   │   ├── method_detail_bloc.dart
│   │   │   │   └── method_search_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── method_list_page.dart
│   │   │   │   ├── method_detail_page.dart
│   │   │   │   └── method_search_page.dart
│   │   │   └── widgets/
│   │   │       ├── method_card.dart
│   │   │       ├── method_filter.dart
│   │   │       ├── difficulty_badge.dart
│   │   │       └── category_tag.dart
│   │   │
│   │   ├── user_methods/                   # 个人方法库模块
│   │   │   ├── bloc/
│   │   │   │   ├── user_method_bloc.dart
│   │   │   │   ├── user_method_event.dart
│   │   │   │   └── user_method_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── user_method_list_page.dart
│   │   │   │   └── user_method_detail_page.dart
│   │   │   └── widgets/
│   │   │       ├── user_method_card.dart
│   │   │       ├── personal_goal_editor.dart
│   │   │       └── favorite_button.dart
│   │   │
│   │   ├── practice/                       # 练习模块
│   │   │   ├── bloc/
│   │   │   │   ├── practice_bloc.dart
│   │   │   │   ├── practice_history_bloc.dart
│   │   │   │   └── practice_stats_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── practice_page.dart
│   │   │   │   ├── practice_history_page.dart
│   │   │   │   └── practice_stats_page.dart
│   │   │   └── widgets/
│   │   │       ├── practice_record_form.dart
│   │   │       ├── mood_slider.dart
│   │   │       ├── duration_picker.dart
│   │   │       ├── practice_card.dart
│   │   │       ├── mood_trend_chart.dart
│   │   │       └── practice_stats_card.dart
│   │   │
│   │   ├── media/                          # 多媒体模块
│   │   │   ├── bloc/
│   │   │   │   ├── audio_player_bloc.dart
│   │   │   │   └── video_player_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── audio_player_page.dart
│   │   │   │   └── video_player_page.dart
│   │   │   └── widgets/
│   │   │       ├── audio_player_controls.dart
│   │   │       ├── video_player_controls.dart
│   │   │       └── playback_progress_bar.dart
│   │   │
│   │   ├── profile/                        # 个人资料模块
│   │   │   ├── bloc/
│   │   │   │   ├── profile_bloc.dart
│   │   │   │   ├── profile_event.dart
│   │   │   │   └── profile_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── profile_page.dart
│   │   │   │   ├── edit_profile_page.dart
│   │   │   │   └── settings_page.dart
│   │   │   └── widgets/
│   │   │       ├── profile_avatar.dart
│   │   │       ├── profile_info_card.dart
│   │   │       └── settings_item.dart
│   │   │
│   │   └── widgets/                        # 共享Widget
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_card.dart
│   │       ├── loading_indicator.dart
│   │       ├── error_widget.dart
│   │       ├── empty_state.dart
│   │       ├── app_scaffold.dart
│   │       └── refresh_indicator.dart
│   │
│   └── injection.dart                      # 依赖注入配置
│
├── test/                                   # 测试
│   ├── unit/                               # 单元测试
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── data/
│   │       └── repositories/
│   ├── widget/                             # Widget测试
│   │   └── presentation/
│   └── integration/                        # 集成测试
│       └── app_test.dart
│
├── assets/                                 # 资源文件
│   ├── images/                             # 图片
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── onboarding/
│   ├── icons/                              # 图标
│   │   └── app_icon.png
│   ├── fonts/                              # 字体
│   └── translations/                       # 国际化文件
│       ├── en.json
│       └── zh.json
│
├── pubspec.yaml                            # 依赖配置
├── analysis_options.yaml                   # 代码分析配置
└── README.md                               # 项目说明
```

## 核心模块设计

### 1. 认证模块

**功能**：
- 用户登录
- 用户注册
- 忘记密码
- Token管理

**状态流转**：
```
AuthInitial → AuthLoading → AuthSuccess/AuthFailure
```

**关键代码示例**：

```dart
// Use Case
class Login {
  final AuthRepository repository;
  
  Login(this.repository);
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email, password);
  }
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUseCase;
  final Logout logoutUseCase;
  
  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

### 2. 方法浏览模块

**功能**：
- 浏览方法列表
- 搜索方法
- 查看方法详情
- 按分类/难度筛选

**数据模型**：

```dart
@freezed
class Method with _$Method {
  const factory Method({
    required int id,
    required String name,
    required String description,
    required String category,
    required String difficulty,
    int? durationMinutes,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    required int viewCount,
    required DateTime createdAt,
  }) = _Method;
}
```

### 3. 个人方法库模块

**功能**：
- 添加方法到个人库
- 查看个人方法列表
- 设置个人目标
- 收藏管理

**业务逻辑**：

```dart
class AddMethodToLibrary {
  final UserMethodRepository repository;
  
  AddMethodToLibrary(this.repository);
  
  Future<Either<Failure, UserMethod>> call({
    required int methodId,
    String? personalGoal,
  }) async {
    return await repository.addMethodToLibrary(
      methodId: methodId,
      personalGoal: personalGoal,
    );
  }
}
```

### 4. 练习记录模块

**功能**：
- 记录练习
- 查看练习历史
- 查看练习统计
- 心理状态趋势分析

**数据图表**：
- 使用`fl_chart`库展示趋势图
- 显示心理状态变化
- 显示练习频率

### 5. 多媒体播放模块

**功能**：
- 音频播放（冥想引导音频）
- 视频播放（教学视频）
- 播放控制（播放/暂停/进度）
- 播放进度保存

**状态管理**：

```dart
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  
  AudioPlayerBloc(this._audioPlayer) : super(AudioPlayerInitial()) {
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<SeekAudio>(_onSeekAudio);
  }
  
  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayer.setUrl(event.url);
      await _audioPlayer.play();
      emit(AudioPlayerPlaying());
    } catch (e) {
      emit(AudioPlayerError(e.toString()));
    }
  }
}
```

## 数据流转

### API请求流程

```
UI (Widget) 
  ↓ [触发事件]
BLoC
  ↓ [调用UseCase]
UseCase
  ↓ [调用Repository]
Repository
  ↓ [选择数据源]
Remote Data Source / Local Data Source
  ↓ [请求数据]
API / Database
  ↓ [返回数据]
Repository (转换Model→Entity)
  ↓ [返回Either<Failure, Entity>]
UseCase
  ↓ [返回结果]
BLoC (更新状态)
  ↓ [发送新状态]
UI (Widget重建)
```

### 缓存策略

**网络优先（Network First）**：
```dart
Future<Either<Failure, List<Method>>> getMethods() async {
  try {
    // 1. 尝试从网络获取
    final methods = await remoteDataSource.getMethods();
    // 2. 缓存到本地
    await localDataSource.cacheMethods(methods);
    return Right(methods);
  } on ServerException {
    // 3. 网络失败，从缓存获取
    try {
      final cachedMethods = await localDataSource.getCachedMethods();
      return Right(cachedMethods);
    } on CacheException {
      return Left(CacheFailure('无法获取数据'));
    }
  }
}
```

**缓存优先（Cache First）**：
```dart
Future<Either<Failure, Method>> getMethodDetail(int id) async {
  try {
    // 1. 先从缓存获取
    final cachedMethod = await localDataSource.getMethodById(id);
    // 2. 异步更新缓存
    _updateCache(id);
    return Right(cachedMethod);
  } on CacheException {
    // 3. 缓存未命中，从网络获取
    try {
      final method = await remoteDataSource.getMethodDetail(id);
      await localDataSource.cacheMethod(method);
      return Right(method);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## 路由管理

使用`go_router`实现声明式路由：

```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'methods',
          builder: (context, state) => const MethodListPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return MethodDetailPage(methodId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'my-methods',
          builder: (context, state) => const UserMethodListPage(),
        ),
        GoRoute(
          path: 'practice',
          builder: (context, state) => const PracticeHistoryPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = getIt<SecureStorage>().hasToken();
    final isLoggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register';
    
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    if (isLoggedIn && isLoggingIn) {
      return '/home';
    }
    
    return null;
  },
);
```

## 主题设计

### 颜色方案

```dart
class AppColors {
  // 主色调 - 蓝色系（平静、专业）
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // 辅助色 - 绿色系（成长、健康）
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  
  // 语义色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 中性色
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}
```

### 主题配置

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTextStyles.textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.textTheme,
  );
}
```

## 依赖注入

使用`get_it` + `injectable`实现依赖注入：

```dart
@InjectableInit()
Future<void> configureDependencies() async {
  final getIt = GetIt.instance;
  
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => Login(getIt()));
  getIt.registerLazySingleton(() => Register(getIt()));
  getIt.registerLazySingleton(() => Logout(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
  ));
}
```

## 错误处理

### 统一错误处理

```dart
// Repository层错误处理
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('未知错误'));
  }
}

// BLoC层错误处理
result.fold(
  (failure) {
    if (failure is ServerFailure) {
      emit(AuthFailure(failure.message));
    } else if (failure is ValidationFailure) {
      emit(AuthValidationError(failure.message));
    } else {
      emit(AuthFailure('发生未知错误'));
    }
  },
  (user) => emit(AuthSuccess(user)),
);

// UI层错误展示
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

## 性能优化

### 1. Widget优化

- 使用`const`构造函数
- 提取可复用Widget
- 避免在build方法中创建对象
- 使用`ListView.builder`懒加载

### 2. 图片优化

- 使用`cached_network_image`缓存图片
- 使用WebP格式减小体积
- 使用占位符和淡入动画

### 3. 状态优化

- 使用`Equatable`避免不必要的重建
- 合理划分BLoC粒度
- 使用`BlocSelector`精确监听状态

### 4. 数据库优化

- 创建索引加速查询
- 使用批量操作
- 定期清理过期缓存

## 测试策略

### 单元测试

- 测试所有Use Cases
- 测试Repository实现
- 测试工具函数
- 目标覆盖率：>80%

### Widget测试

- 测试关键页面
- 测试自定义Widget
- 测试用户交互

### 集成测试

- 测试完整用户流程
- 测试跨页面导航
- 测试数据持久化

## 构建和部署

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
flutter build macos --release  # macOS
flutter build windows --release  # Windows
flutter build linux --release  # Linux
```

## 下一步开发计划

1. **Phase 1**：搭建项目架构和依赖注入
2. **Phase 2**：实现认证模块
3. **Phase 3**：实现方法浏览模块
4. **Phase 4**：实现个人方法库模块
5. **Phase 5**：实现练习记录模块
6. **Phase 6**：实现多媒体播放模块
7. **Phase 7**：实现个人资料模块
8. **Phase 8**：优化和测试

---

**文档版本**：1.0.0  
**最后更新**：2024-12-31  
**维护者**：Mental App Team
# Flutter应用架构设计文档

## 概述

本文档详细描述了Nian心理自助应用Flutter客户端的架构设计、技术选型和实现方案。该应用将支持Android、iOS、Web、macOS和Windows五个平台。

## 技术栈

### 核心框架
- **Flutter**：3.16+
- **Dart**：3.2+

### 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_bloc: ^8.1.3          # BLoC状态管理
  equatable: ^2.0.5             # 对象相等性比较
  
  # 依赖注入
  get_it: ^7.6.4                # 服务定位器
  injectable: ^2.3.2            # 依赖注入代码生成
  
  # 网络请求
  dio: ^5.4.0                   # HTTP客户端
  retrofit: ^4.0.3              # 类型安全的API客户端
  connectivity_plus: ^5.0.2     # 网络连接检测
  
  # 本地存储
  shared_preferences: ^2.2.2    # 键值对存储
  sqflite: ^2.3.2               # SQLite数据库
  flutter_secure_storage: ^9.0.0 # 安全存储
  
  # 路由管理
  go_router: ^12.1.3            # 声明式路由
  
  # UI组件
  cached_network_image: ^3.3.0  # 图片缓存
  flutter_svg: ^2.0.9           # SVG支持
  shimmer: ^3.0.0               # 骨架屏效果
  flutter_spinkit: ^5.2.0       # 加载动画
  
  # 多媒体
  just_audio: ^0.9.36           # 音频播放
  video_player: ^2.8.1          # 视频播放
  
  # 图表
  fl_chart: ^0.66.0             # 数据图表
  
  # 工具
  intl: ^0.18.0                 # 国际化
  logger: ^2.0.2                # 日志工具
  dartz: ^0.10.1                # 函数式编程
  freezed_annotation: ^2.4.1    # 不可变对象
  json_annotation: ^4.8.1       # JSON序列化

dev_dependencies:
  # 测试
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4               # Mock工具
  bloc_test: ^9.1.5             # BLoC测试
  
  # 代码生成
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  retrofit_generator: ^8.0.6
  
  # 代码检查
  flutter_lints: ^3.0.1
```

## 架构设计

### Clean Architecture

应用采用Clean Architecture（清洁架构）分层设计，确保代码的可维护性、可测试性和可扩展性。

```
┌──────────────────────────────────────────┐
│                                          │
│          Presentation Layer              │
│                                          │
│  ┌────────────┐      ┌────────────┐     │
│  │  Widgets   │◄─────┤   BLoC     │     │
│  └────────────┘      └─────▲──────┘     │
│                             │            │
└─────────────────────────────┼────────────┘
                              │
┌─────────────────────────────┼────────────┐
│                             │            │
│           Domain Layer      │            │
│                             │            │
│  ┌────────────┐      ┌─────┴──────┐     │
│  │  Entities  │      │  Use Cases │     │
│  └────────────┘      └─────▲──────┘     │
│                             │            │
│  ┌──────────────────────────┴─────┐     │
│  │    Repository Interface        │     │
│  └────────────────────────────────┘     │
│                                          │
└─────────────────────────────────────────┘
                              ▲
┌─────────────────────────────┼────────────┐
│                             │            │
│            Data Layer       │            │
│                             │            │
│  ┌──────────────────────────┴─────┐     │
│  │   Repository Implementation    │     │
│  └─────────────┬──────────────────┘     │
│                │                         │
│  ┌─────────────▼──────────┐             │
│  │  Remote Data Source    │             │
│  │  (API Client)          │             │
│  └────────────────────────┘             │
│                                          │
│  ┌────────────────────────┐             │
│  │  Local Data Source     │             │
│  │  (Database/Cache)      │             │
│  └────────────────────────┘             │
│                                          │
└──────────────────────────────────────────┘
```

### 层级职责

#### Presentation Layer（表现层）

**职责**：
- 展示UI
- 处理用户交互
- 响应状态变化

**组件**：
- **Pages**：完整页面
- **Widgets**：可复用的UI组件
- **BLoC/Cubit**：业务逻辑组件，管理状态

**规则**：
- 不包含业务逻辑
- 只依赖Domain层
- 通过BLoC与Domain层通信

#### Domain Layer（领域层）

**职责**：
- 定义业务实体
- 实现业务逻辑
- 定义Repository接口

**组件**：
- **Entities**：业务实体（纯Dart对象）
- **Use Cases**：用例（单一业务操作）
- **Repository Interfaces**：数据访问接口

**规则**：
- 不依赖任何外部框架
- 不依赖其他层
- 最稳定的层

#### Data Layer（数据层）

**职责**：
- 实现数据访问
- 处理数据转换
- 管理缓存策略

**组件**：
- **Repository Implementations**：Repository接口实现
- **Data Sources**：数据源（Remote/Local）
- **Models**：数据模型（带JSON序列化）

**规则**：
- 实现Domain层定义的接口
- 处理数据的获取和转换
- 负责错误处理

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                           # 应用入口
│   ├── app.dart                            # App根组件
│   │
│   ├── config/                             # 配置
│   │   ├── api_constants.dart              # API常量
│   │   ├── app_config.dart                 # 应用配置
│   │   ├── routes.dart                     # 路由配置
│   │   └── theme/                          # 主题
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── core/                               # 核心功能
│   │   ├── error/                          # 错误处理
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/                        # 网络层
│   │   │   ├── dio_client.dart
│   │   │   └── network_info.dart
│   │   ├── utils/                          # 工具类
│   │   │   ├── date_formatter.dart
│   │   │   ├── validators.dart
│   │   │   ├── logger.dart
│   │   │   └── extensions.dart
│   │   └── constants/                      # 常量
│   │       ├── app_constants.dart
│   │       └── storage_keys.dart
│   │
│   ├── data/                               # 数据层
│   │   ├── models/                         # 数据模型
│   │   │   ├── user_model.dart
│   │   │   ├── method_model.dart
│   │   │   ├── practice_model.dart
│   │   │   └── category_model.dart
│   │   ├── repositories/                   # Repository实现
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── method_repository_impl.dart
│   │   │   ├── user_method_repository_impl.dart
│   │   │   └── practice_repository_impl.dart
│   │   └── datasources/                    # 数据源
│   │       ├── local/                      # 本地数据源
│   │       │   ├── app_database.dart
│   │       │   ├── secure_storage.dart
│   │       │   └── shared_prefs.dart
│   │       └── remote/                     # 远程数据源
│   │           ├── auth_api.dart
│   │           ├── method_api.dart
│   │           ├── user_method_api.dart
│   │           └── practice_api.dart
│   │
│   ├── domain/                             # 领域层
│   │   ├── entities/                       # 业务实体
│   │   │   ├── user.dart
│   │   │   ├── method.dart
│   │   │   ├── user_method.dart
│   │   │   ├── practice_record.dart
│   │   │   └── category.dart
│   │   ├── repositories/                   # Repository接口
│   │   │   ├── auth_repository.dart
│   │   │   ├── method_repository.dart
│   │   │   ├── user_method_repository.dart
│   │   │   └── practice_repository.dart
│   │   └── usecases/                       # 用例
│   │       ├── auth/
│   │       │   ├── login.dart
│   │       │   ├── register.dart
│   │       │   ├── logout.dart
│   │       │   └── get_current_user.dart
│   │       ├── methods/
│   │       │   ├── get_methods.dart
│   │       │   ├── get_method_detail.dart
│   │       │   ├── search_methods.dart
│   │       │   └── get_method_by_category.dart
│   │       ├── user_methods/
│   │       │   ├── add_method_to_library.dart
│   │       │   ├── get_user_methods.dart
│   │       │   ├── update_user_method.dart
│   │       │   └── remove_user_method.dart
│   │       └── practices/
│   │           ├── record_practice.dart
│   │           ├── get_practice_history.dart
│   │           ├── get_practice_stats.dart
│   │           └── get_mood_trend.dart
│   │
│   ├── presentation/                       # 表现层
│   │   ├── auth/                           # 认证模块
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   └── forgot_password_page.dart
│   │   │   └── widgets/
│   │   │       ├── auth_form_field.dart
│   │   │       ├── password_field.dart
│   │   │       └── auth_button.dart
│   │   │
│   │   ├── home/                           # 首页模块
│   │   │   ├── bloc/
│   │   │   │   ├── home_bloc.dart
│   │   │   │   ├── home_event.dart
│   │   │   │   └── home_state.dart
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   └── widgets/
│   │   │       ├── category_chip.dart
│   │   │       ├── featured_method_card.dart
│   │   │       └── quick_stats.dart
│   │   │
│   │   ├── methods/                        # 方法浏览模块
│   │   │   ├── bloc/
│   │   │   │   ├── method_list_bloc.dart
│   │   │   │   ├── method_detail_bloc.dart
│   │   │   │   └── method_search_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── method_list_page.dart
│   │   │   │   ├── method_detail_page.dart
│   │   │   │   └── method_search_page.dart
│   │   │   └── widgets/
│   │   │       ├── method_card.dart
│   │   │       ├── method_filter.dart
│   │   │       ├── difficulty_badge.dart
│   │   │       └── category_tag.dart
│   │   │
│   │   ├── user_methods/                   # 个人方法库模块
│   │   │   ├── bloc/
│   │   │   │   ├── user_method_bloc.dart
│   │   │   │   ├── user_method_event.dart
│   │   │   │   └── user_method_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── user_method_list_page.dart
│   │   │   │   └── user_method_detail_page.dart
│   │   │   └── widgets/
│   │   │       ├── user_method_card.dart
│   │   │       ├── personal_goal_editor.dart
│   │   │       └── favorite_button.dart
│   │   │
│   │   ├── practice/                       # 练习模块
│   │   │   ├── bloc/
│   │   │   │   ├── practice_bloc.dart
│   │   │   │   ├── practice_history_bloc.dart
│   │   │   │   └── practice_stats_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── practice_page.dart
│   │   │   │   ├── practice_history_page.dart
│   │   │   │   └── practice_stats_page.dart
│   │   │   └── widgets/
│   │   │       ├── practice_record_form.dart
│   │   │       ├── mood_slider.dart
│   │   │       ├── duration_picker.dart
│   │   │       ├── practice_card.dart
│   │   │       ├── mood_trend_chart.dart
│   │   │       └── practice_stats_card.dart
│   │   │
│   │   ├── media/                          # 多媒体模块
│   │   │   ├── bloc/
│   │   │   │   ├── audio_player_bloc.dart
│   │   │   │   └── video_player_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── audio_player_page.dart
│   │   │   │   └── video_player_page.dart
│   │   │   └── widgets/
│   │   │       ├── audio_player_controls.dart
│   │   │       ├── video_player_controls.dart
│   │   │       └── playback_progress_bar.dart
│   │   │
│   │   ├── profile/                        # 个人资料模块
│   │   │   ├── bloc/
│   │   │   │   ├── profile_bloc.dart
│   │   │   │   ├── profile_event.dart
│   │   │   │   └── profile_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── profile_page.dart
│   │   │   │   ├── edit_profile_page.dart
│   │   │   │   └── settings_page.dart
│   │   │   └── widgets/
│   │   │       ├── profile_avatar.dart
│   │   │       ├── profile_info_card.dart
│   │   │       └── settings_item.dart
│   │   │
│   │   └── widgets/                        # 共享Widget
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_card.dart
│   │       ├── loading_indicator.dart
│   │       ├── error_widget.dart
│   │       ├── empty_state.dart
│   │       ├── app_scaffold.dart
│   │       └── refresh_indicator.dart
│   │
│   └── injection.dart                      # 依赖注入配置
│
├── test/                                   # 测试
│   ├── unit/                               # 单元测试
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── data/
│   │       └── repositories/
│   ├── widget/                             # Widget测试
│   │   └── presentation/
│   └── integration/                        # 集成测试
│       └── app_test.dart
│
├── assets/                                 # 资源文件
│   ├── images/                             # 图片
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── onboarding/
│   ├── icons/                              # 图标
│   │   └── app_icon.png
│   ├── fonts/                              # 字体
│   └── translations/                       # 国际化文件
│       ├── en.json
│       └── zh.json
│
├── pubspec.yaml                            # 依赖配置
├── analysis_options.yaml                   # 代码分析配置
└── README.md                               # 项目说明
```

## 核心模块设计

### 1. 认证模块

**功能**：
- 用户登录
- 用户注册
- 忘记密码
- Token管理

**状态流转**：
```
AuthInitial → AuthLoading → AuthSuccess/AuthFailure
```

**关键代码示例**：

```dart
// Use Case
class Login {
  final AuthRepository repository;
  
  Login(this.repository);
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email, password);
  }
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUseCase;
  final Logout logoutUseCase;
  
  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

### 2. 方法浏览模块

**功能**：
- 浏览方法列表
- 搜索方法
- 查看方法详情
- 按分类/难度筛选

**数据模型**：

```dart
@freezed
class Method with _$Method {
  const factory Method({
    required int id,
    required String name,
    required String description,
    required String category,
    required String difficulty,
    int? durationMinutes,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    required int viewCount,
    required DateTime createdAt,
  }) = _Method;
}
```

### 3. 个人方法库模块

**功能**：
- 添加方法到个人库
- 查看个人方法列表
- 设置个人目标
- 收藏管理

**业务逻辑**：

```dart
class AddMethodToLibrary {
  final UserMethodRepository repository;
  
  AddMethodToLibrary(this.repository);
  
  Future<Either<Failure, UserMethod>> call({
    required int methodId,
    String? personalGoal,
  }) async {
    return await repository.addMethodToLibrary(
      methodId: methodId,
      personalGoal: personalGoal,
    );
  }
}
```

### 4. 练习记录模块

**功能**：
- 记录练习
- 查看练习历史
- 查看练习统计
- 心理状态趋势分析

**数据图表**：
- 使用`fl_chart`库展示趋势图
- 显示心理状态变化
- 显示练习频率

### 5. 多媒体播放模块

**功能**：
- 音频播放（冥想引导音频）
- 视频播放（教学视频）
- 播放控制（播放/暂停/进度）
- 播放进度保存

**状态管理**：

```dart
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  
  AudioPlayerBloc(this._audioPlayer) : super(AudioPlayerInitial()) {
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<SeekAudio>(_onSeekAudio);
  }
  
  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayer.setUrl(event.url);
      await _audioPlayer.play();
      emit(AudioPlayerPlaying());
    } catch (e) {
      emit(AudioPlayerError(e.toString()));
    }
  }
}
```

## 数据流转

### API请求流程

```
UI (Widget) 
  ↓ [触发事件]
BLoC
  ↓ [调用UseCase]
UseCase
  ↓ [调用Repository]
Repository
  ↓ [选择数据源]
Remote Data Source / Local Data Source
  ↓ [请求数据]
API / Database
  ↓ [返回数据]
Repository (转换Model→Entity)
  ↓ [返回Either<Failure, Entity>]
UseCase
  ↓ [返回结果]
BLoC (更新状态)
  ↓ [发送新状态]
UI (Widget重建)
```

### 缓存策略

**网络优先（Network First）**：
```dart
Future<Either<Failure, List<Method>>> getMethods() async {
  try {
    // 1. 尝试从网络获取
    final methods = await remoteDataSource.getMethods();
    // 2. 缓存到本地
    await localDataSource.cacheMethods(methods);
    return Right(methods);
  } on ServerException {
    // 3. 网络失败，从缓存获取
    try {
      final cachedMethods = await localDataSource.getCachedMethods();
      return Right(cachedMethods);
    } on CacheException {
      return Left(CacheFailure('无法获取数据'));
    }
  }
}
```

**缓存优先（Cache First）**：
```dart
Future<Either<Failure, Method>> getMethodDetail(int id) async {
  try {
    // 1. 先从缓存获取
    final cachedMethod = await localDataSource.getMethodById(id);
    // 2. 异步更新缓存
    _updateCache(id);
    return Right(cachedMethod);
  } on CacheException {
    // 3. 缓存未命中，从网络获取
    try {
      final method = await remoteDataSource.getMethodDetail(id);
      await localDataSource.cacheMethod(method);
      return Right(method);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## 路由管理

使用`go_router`实现声明式路由：

```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'methods',
          builder: (context, state) => const MethodListPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return MethodDetailPage(methodId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'my-methods',
          builder: (context, state) => const UserMethodListPage(),
        ),
        GoRoute(
          path: 'practice',
          builder: (context, state) => const PracticeHistoryPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = getIt<SecureStorage>().hasToken();
    final isLoggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register';
    
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    if (isLoggedIn && isLoggingIn) {
      return '/home';
    }
    
    return null;
  },
);
```

## 主题设计

### 颜色方案

```dart
class AppColors {
  // 主色调 - 蓝色系（平静、专业）
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // 辅助色 - 绿色系（成长、健康）
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);
  
  // 语义色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 中性色
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}
```

### 主题配置

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTextStyles.textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.textTheme,
  );
}
```

## 依赖注入

使用`get_it` + `injectable`实现依赖注入：

```dart
@InjectableInit()
Future<void> configureDependencies() async {
  final getIt = GetIt.instance;
  
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => Login(getIt()));
  getIt.registerLazySingleton(() => Register(getIt()));
  getIt.registerLazySingleton(() => Logout(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
  ));
}
```

## 错误处理

### 统一错误处理

```dart
// Repository层错误处理
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('未知错误'));
  }
}

// BLoC层错误处理
result.fold(
  (failure) {
    if (failure is ServerFailure) {
      emit(AuthFailure(failure.message));
    } else if (failure is ValidationFailure) {
      emit(AuthValidationError(failure.message));
    } else {
      emit(AuthFailure('发生未知错误'));
    }
  },
  (user) => emit(AuthSuccess(user)),
);

// UI层错误展示
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: ...,
)
```

## 性能优化

### 1. Widget优化

- 使用`const`构造函数
- 提取可复用Widget
- 避免在build方法中创建对象
- 使用`ListView.builder`懒加载

### 2. 图片优化

- 使用`cached_network_image`缓存图片
- 使用WebP格式减小体积
- 使用占位符和淡入动画

### 3. 状态优化

- 使用`Equatable`避免不必要的重建
- 合理划分BLoC粒度
- 使用`BlocSelector`精确监听状态

### 4. 数据库优化

- 创建索引加速查询
- 使用批量操作
- 定期清理过期缓存

## 测试策略

### 单元测试

- 测试所有Use Cases
- 测试Repository实现
- 测试工具函数
- 目标覆盖率：>80%

### Widget测试

- 测试关键页面
- 测试自定义Widget
- 测试用户交互

### 集成测试

- 测试完整用户流程
- 测试跨页面导航
- 测试数据持久化

## 构建和部署

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
flutter build macos --release  # macOS
flutter build windows --release  # Windows
flutter build linux --release  # Linux
```

## 下一步开发计划

1. **Phase 1**：搭建项目架构和依赖注入
2. **Phase 2**：实现认证模块
3. **Phase 3**：实现方法浏览模块
4. **Phase 4**：实现个人方法库模块
5. **Phase 5**：实现练习记录模块
6. **Phase 6**：实现多媒体播放模块
7. **Phase 7**：实现个人资料模块
8. **Phase 8**：优化和测试

---

**文档版本**：1.0.0  
**最后更新**：2024-12-31  
**维护者**：Mental App Team
