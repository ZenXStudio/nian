# Flutter应用开发规范文档

## 概述

本文档规定了Nian应用Flutter客户端的开发规范、架构设计、编码标准和最佳实践。所有开发人员必须遵循本文档的规范进行开发。

## 目录

1. [项目架构](#项目架构)
2. [目录结构](#目录结构)
3. [命名规范](#命名规范)
4. [代码风格](#代码风格)
5. [状态管理](#状态管理)
6. [网络请求](#网络请求)
7. [本地存储](#本地存储)
8. [错误处理](#错误处理)
9. [国际化](#国际化)
10. [测试规范](#测试规范)
11. [性能优化](#性能优化)
12. [安全规范](#安全规范)

## 项目架构

### 架构模式

本项目采用**Clean Architecture（清洁架构）**结合**BLoC模式**进行开发。

架构分层：

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │  <- Flutter Widgets + BLoC
├─────────────────────────────────────┤
│     Domain Layer (Business Logic)   │  <- Use Cases + Entities
├─────────────────────────────────────┤
│     Data Layer (Data Access)        │  <- Repositories + Data Sources
└─────────────────────────────────────┘
```

### 层级职责

**Presentation Layer（表现层）**
- 职责：UI展示、用户交互、状态管理
- 组成：Widgets、Pages、BLoC/Cubit
- 原则：不包含业务逻辑，只负责UI展示和用户输入

**Domain Layer（领域层）**
- 职责：核心业务逻辑
- 组成：Entities、Use Cases、Repository接口
- 原则：独立于外部框架，可复用

**Data Layer（数据层）**
- 职责：数据获取和存储
- 组成：Repository实现、Data Sources（Remote/Local）、Models
- 原则：实现Domain层定义的接口

### 依赖规则

- Presentation层依赖Domain层
- Data层依赖Domain层
- Domain层不依赖任何层（最内层，最稳定）
- 依赖方向始终向内（向Domain层）

## 目录结构

```
flutter_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── app.dart                     # 应用根组件
│   │
│   ├── config/                      # 配置文件
│   │   ├── api_constants.dart       # API常量
│   │   ├── app_config.dart          # 应用配置
│   │   ├── routes.dart              # 路由配置
│   │   └── theme.dart               # 主题配置
│   │
│   ├── core/                        # 核心功能（跨模块共享）
│   │   ├── error/                   # 错误处理
│   │   │   ├── exceptions.dart      # 异常定义
│   │   │   └── failures.dart        # 失败类型定义
│   │   ├── network/                 # 网络层
│   │   │   ├── dio_client.dart      # Dio客户端封装
│   │   │   └── network_info.dart    # 网络状态检查
│   │   ├── utils/                   # 工具类
│   │   │   ├── date_utils.dart      # 日期工具
│   │   │   ├── validators.dart      # 验证器
│   │   │   └── logger.dart          # 日志工具
│   │   └── constants/               # 常量
│   │       ├── app_constants.dart   # 应用常量
│   │       └── storage_keys.dart    # 存储键名
│   │
│   ├── data/                        # 数据层
│   │   ├── models/                  # 数据模型（JSON序列化）
│   │   │   ├── user_model.dart
│   │   │   ├── method_model.dart
│   │   │   └── practice_model.dart
│   │   ├── repositories/            # Repository实现
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── method_repository_impl.dart
│   │   │   └── practice_repository_impl.dart
│   │   └── datasources/             # 数据源
│   │       ├── local/               # 本地数据源
│   │       │   ├── database_helper.dart
│   │       │   ├── secure_storage.dart
│   │       │   └── shared_prefs.dart
│   │       └── remote/              # 远程数据源
│   │           ├── auth_api.dart
│   │           ├── method_api.dart
│   │           └── practice_api.dart
│   │
│   ├── domain/                      # 领域层
│   │   ├── entities/                # 业务实体
│   │   │   ├── user.dart
│   │   │   ├── method.dart
│   │   │   └── practice_record.dart
│   │   ├── repositories/            # Repository接口
│   │   │   ├── auth_repository.dart
│   │   │   ├── method_repository.dart
│   │   │   └── practice_repository.dart
│   │   └── usecases/                # 用例（业务逻辑）
│   │       ├── auth/
│   │       │   ├── login.dart
│   │       │   ├── register.dart
│   │       │   └── logout.dart
│   │       ├── methods/
│   │       │   ├── get_methods.dart
│   │       │   ├── get_method_detail.dart
│   │       │   └── search_methods.dart
│   │       └── practices/
│   │           ├── record_practice.dart
│   │           └── get_practice_history.dart
│   │
│   ├── presentation/                # 表现层
│   │   ├── auth/                    # 认证模块
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── register_page.dart
│   │   │   └── widgets/
│   │   │       ├── login_form.dart
│   │   │       └── password_field.dart
│   │   ├── home/                    # 首页模块
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   └── widgets/
│   │   ├── methods/                 # 方法模块
│   │   │   ├── bloc/
│   │   │   │   ├── method_list_bloc.dart
│   │   │   │   └── method_detail_bloc.dart
│   │   │   ├── pages/
│   │   │   │   ├── method_list_page.dart
│   │   │   │   └── method_detail_page.dart
│   │   │   └── widgets/
│   │   │       ├── method_card.dart
│   │   │       └── category_filter.dart
│   │   ├── practice/                # 练习模块
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   │   ├── practice_page.dart
│   │   │   │   └── practice_history_page.dart
│   │   │   └── widgets/
│   │   ├── profile/                 # 个人资料模块
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   │   └── profile_page.dart
│   │   │   └── widgets/
│   │   └── widgets/                 # 共享Widget
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── loading_indicator.dart
│   │       └── error_widget.dart
│   │
│   └── injection.dart               # 依赖注入配置
│
├── test/                            # 测试文件
│   ├── unit/                        # 单元测试
│   ├── widget/                      # Widget测试
│   └── integration/                 # 集成测试
│
├── assets/                          # 资源文件
│   ├── images/                      # 图片资源
│   ├── icons/                       # 图标资源
│   ├── fonts/                       # 字体资源
│   └── translations/                # 国际化文件
│       ├── en.json
│       └── zh.json
│
├── pubspec.yaml                     # 项目依赖配置
├── analysis_options.yaml            # Dart分析器配置
└── README.md                        # 项目说明
```

## 命名规范

### 文件命名

- 使用**snake_case**（小写字母+下划线）
- 文件名应清晰描述其内容

```dart
// ✅ 正确
user_profile_page.dart
auth_repository_impl.dart
method_card_widget.dart

// ❌ 错误
UserProfilePage.dart
authRepositoryImpl.dart
MethodCard.dart
```

### 类命名

- 使用**PascalCase**（首字母大写驼峰）
- 类名应为名词或名词短语

```dart
// ✅ 正确
class UserProfile { }
class AuthRepository { }
class MethodCard extends StatelessWidget { }

// ❌ 错误
class userProfile { }
class auth_repository { }
```

### 变量和方法命名

- 使用**camelCase**（首字母小写驼峰）
- 私有成员使用下划线前缀

```dart
// ✅ 正确
String userName;
int userId;
void fetchUserData() { }
String _privateField;

// ❌ 错误
String UserName;
String user_name;
void FetchUserData() { }
```

### 常量命名

- 使用**lowerCamelCase**（首字母小写驼峰）

```dart
// ✅ 正确
const String apiBaseUrl = 'https://api.example.com';
const int maxRetryCount = 3;

// ❌ 错误
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_COUNT = 3;
```

### 枚举命名

- 枚举类型使用**PascalCase**
- 枚举值使用**camelCase**

```dart
// ✅ 正确
enum UserStatus {
  active,
  inactive,
  pending
}

// ❌ 错误
enum userStatus {
  Active,
  InActive,
  PENDING
}
```

## 代码风格

### Dart分析器配置

在`analysis_options.yaml`中启用严格的代码检查：

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_types_as_parameter_names
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - require_trailing_commas
    - use_key_in_widget_constructors
```

### 代码格式化

使用`dart format`自动格式化代码：

```bash
dart format lib/
```

### 注释规范

**文档注释**：使用三斜线`///`

```dart
/// 用户认证Repository
///
/// 提供用户登录、注册、登出等功能
class AuthRepository {
  /// 用户登录
  ///
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// 返回登录成功后的用户信息
  Future<User> login(String email, String password) async {
    // 实现代码
  }
}
```

**单行注释**：简短说明使用`//`

```dart
// 验证邮箱格式
if (!EmailValidator.validate(email)) {
  throw InvalidEmailException();
}
```

### Widget构建规范

**使用const构造函数**（提升性能）

```dart
// ✅ 正确
const Text('Hello');
const SizedBox(height: 16);

// ❌ 错误
Text('Hello');
SizedBox(height: 16);
```

**提取可复用的Widget**

```dart
// ✅ 正确
class _TitleText extends StatelessWidget {
  final String text;
  
  const _TitleText(this.text);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

// ❌ 错误：在build方法中重复构建复杂Widget
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Title 1', style: Theme.of(context).textTheme.titleLarge),
      Text('Title 2', style: Theme.of(context).textTheme.titleLarge),
      Text('Title 3', style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}
```

### 异步编程规范

**优先使用async/await**

```dart
// ✅ 正确
Future<User> fetchUser(int id) async {
  try {
    final response = await _apiClient.get('/users/$id');
    return User.fromJson(response.data);
  } catch (e) {
    throw FetchUserException(e);
  }
}

// ❌ 错误：使用.then()链式调用
Future<User> fetchUser(int id) {
  return _apiClient.get('/users/$id').then((response) {
    return User.fromJson(response.data);
  }).catchError((e) {
    throw FetchUserException(e);
  });
}
```

## 状态管理

### 使用BLoC模式

本项目使用`flutter_bloc`库进行状态管理。

**BLoC结构**

```dart
// Event
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  LoginRequested(this.email, this.password);
}

// State
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  
  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _loginUseCase.execute(
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

**在Widget中使用BLoC**

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return LoginForm();
        },
      ),
    );
  }
}
```

### 状态管理最佳实践

1. **单一职责**：每个BLoC只管理一个功能模块
2. **不可变状态**：State应该是不可变的
3. **使用Equatable**：为Event和State实现相等性比较
4. **错误处理**：在BLoC中统一处理错误
5. **避免UI逻辑**：不在BLoC中编写UI相关代码

## 网络请求

### Dio客户端封装

```dart
class DioClient {
  late final Dio _dio;
  
  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.addAll([
      _authInterceptor(),
      _logInterceptor(),
      _errorInterceptor(),
    ]);
  }
  
  // 添加认证token
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getIt<SecureStorage>().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }
  
  // 日志拦截器
  Interceptor _logInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (log) => AppLogger.debug(log.toString()),
    );
  }
  
  // 错误处理拦截器
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token过期，跳转登录页
          getIt<NavigationService>().navigateToLogin();
        }
        handler.next(error);
      },
    );
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

### API调用示例

```dart
class MethodRemoteDataSource {
  final DioClient _dioClient;
  
  MethodRemoteDataSource(this._dioClient);
  
  Future<List<MethodModel>> getMethods({
    String? category,
    String? difficulty,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        '/methods',
        queryParameters: {
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => MethodModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('连接超时，请检查网络');
      case DioExceptionType.badResponse:
        return ServerException(
          error.response?.data['message'] ?? '服务器错误',
        );
      case DioExceptionType.cancel:
        return ServerException('请求已取消');
      default:
        return ServerException('网络连接失败');
    }
  }
}
```

## 本地存储

### 存储策略

- **安全数据**（token、密码）：使用`flutter_secure_storage`
- **用户偏好**（设置、主题）：使用`shared_preferences`
- **结构化数据**（方法、练习记录）：使用`sqflite`

### Secure Storage

```dart
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }
}
```

### Shared Preferences

```dart
class SharedPrefs {
  final SharedPreferences _prefs;
  
  SharedPrefs(this._prefs);
  
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(StorageKeys.themeMode, mode);
  }
  
  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }
}
```

### SQLite数据库

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nian.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE methods (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        cached_at INTEGER
      )
    ''');
  }
}
```

## 错误处理

### 异常层次结构

```dart
// 基础异常
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

// 网络异常
class ServerException extends AppException {
  ServerException(String message) : super(message);
}

// 缓存异常
class CacheException extends AppException {
  CacheException(String message) : super(message);
}

// 验证异常
class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}
```

### Failure类型

```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
```

### Either模式

使用`dartz`库的`Either`类型处理成功/失败：

```dart
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await _authApi.login(email, password);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('未知错误'));
  }
}
```

## 国际化

### 配置国际化

在`pubspec.yaml`中添加：

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

flutter:
  generate: true
```

创建`l10n.yaml`：

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 翻译文件

`lib/l10n/app_en.arb`：

```json
{
  "@@locale": "en",
  "appTitle": "Mental Health App",
  "login": "Login",
  "email": "Email",
  "password": "Password",
  "loginButton": "Sign In",
  "welcomeMessage": "Welcome, {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

`lib/l10n/app_zh.arb`：

```json
{
  "@@locale": "zh",
  "appTitle": "心理健康应用",
  "login": "登录",
  "email": "邮箱",
  "password": "密码",
  "loginButton": "登录",
  "welcomeMessage": "欢迎, {name}!"
}
```

### 使用国际化

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.appTitle);
}
```

## 测试规范

### 单元测试

测试UseCase、Repository、DataSource等业务逻辑：

```dart
void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });
  
  group('LoginUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(id: 1, email: testEmail, nickname: 'Test');
    
    test('should return User when login is successful', () async {
      // arrange
      when(mockAuthRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Right(testUser));
      
      // act
      final result = await loginUseCase.execute(
        email: testEmail,
        password: testPassword,
      );
      
      // assert
      expect(result, Right(testUser));
      verify(mockAuthRepository.login(testEmail, testPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });
    
    test('should return ServerFailure when login fails', () async {
      // arrange
      when(mockAuthRepository.login(testEmail, testPassword))
          .thenAnswer((_) async => Left(ServerFailure('Login failed')));
      
      // act
      final result = await loginUseCase.execute(
        email: testEmail,
        password: testPassword,
      );
      
      // assert
      expect(result, Left(ServerFailure('Login failed')));
    });
  });
}
```

### Widget测试

测试UI组件：

```dart
void main() {
  testWidgets('LoginForm should display email and password fields',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );
    
    // Find widgets
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
  
  testWidgets('LoginForm should call onSubmit when button is pressed',
      (WidgetTester tester) async {
    bool submitted = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginForm(
            onSubmit: (email, password) {
              submitted = true;
            },
          ),
        ),
      ),
    );
    
    // Enter text
    await tester.enterText(
      find.byType(TextField).first,
      'test@example.com',
    );
    await tester.enterText(
      find.byType(TextField).last,
      'password123',
    );
    
    // Tap button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    expect(submitted, true);
  });
}
```

## 性能优化

### 列表优化

使用`ListView.builder`而非`ListView`：

```dart
// ✅ 正确：懒加载
ListView.builder(
  itemCount: methods.length,
  itemBuilder: (context, index) {
    return MethodCard(method: methods[index]);
  },
)

// ❌ 错误：一次性加载所有子项
ListView(
  children: methods.map((m) => MethodCard(method: m)).toList(),
)
```

### 图片优化

使用`cached_network_image`缓存网络图片：

```dart
CachedNetworkImage(
  imageUrl: method.imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInDuration: const Duration(milliseconds: 500),
)
```

### const构造函数

尽可能使用const构造函数：

```dart
const Text('Title')
const Icon(Icons.home)
const Padding(padding: EdgeInsets.all(16))
```

### Key的使用

为列表项使用正确的Key：

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return MethodCard(
      key: ValueKey(items[index].id),
      method: items[index],
    );
  },
)
```

## 安全规范

### 敏感数据保护

1. **永远不要在代码中硬编码敏感信息**
2. **使用flutter_secure_storage存储token**
3. **使用HTTPS通信**
4. **不在日志中输出敏感信息**

### 输入验证

```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!EmailValidator.validate(value)) {
      return '邮箱格式不正确';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6位';
    }
    return null;
  }
}
```

### 证书固定（可选）

对于高安全要求的应用，可实现SSL证书固定：

```dart
class DioClient {
  Dio _createDio() {
    final dio = Dio();
    
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        // 验证证书
        return cert.pem == expectedCertificatePem;
      };
      return client;
    };
    
    return dio;
  }
}
```

## Git规范

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

类型（type）：
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档修改
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

示例：
```
feat(auth): add biometric authentication

Implement fingerprint and face recognition login

Closes #123
```

## 附录

### 推荐依赖包

```yaml
dependencies:
  # 状态管理
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # 网络请求
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # 本地存储
  shared_preferences: ^2.2.2
  sqflite: ^2.3.2
  flutter_secure_storage: ^9.0.0
  
  # 路由
  go_router: ^12.1.3
  
  # UI组件
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  
  # 多媒体
  just_audio: ^0.9.36
  video_player: ^2.8.1
  
  # 工具
  intl: ^0.18.0
  logger: ^2.0.2
  dartz: ^0.10.1

dev_dependencies:
  # 测试
  mockito: ^5.4.4
  build_runner: ^2.4.7
  
  # 代码检查
  flutter_lints: ^3.0.1
```

### 参考资源

- [Flutter官方文档](https://docs.flutter.dev/)
- [Dart编码规范](https://dart.dev/guides/language/effective-dart)
- [BLoC库文档](https://bloclibrary.dev/)
- [Flutter架构示例](https://github.com/ResoCoder/flutter-ddd-clean-architecture)

---

**文档版本**：1.0.0  
**最后更新**：2024-12-31  
**维护者**：Mental App Team
