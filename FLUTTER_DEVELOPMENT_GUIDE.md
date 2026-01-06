# Flutter开发规范

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件 | snake_case | `user_model.dart` |
| 类 | PascalCase | `UserModel` |
| 变量/方法 | camelCase | `getUserById` |
| 常量 | camelCase 或 UPPER_CASE | `apiBaseUrl` |
| 私有成员 | 前缀下划线 | `_privateMethod` |

## 代码风格

### Widget构建
```dart
// 推荐：使用const优化
const SizedBox(height: 16),

// 推荐：提取Widget减少嵌套
Widget _buildHeader() {
  return Column(...);
}
```

### BLoC使用
```dart
// Event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested(this.email, this.password);
}

// State
class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
}

// BLoC
on<LoginRequested>((event, emit) async {
  emit(AuthLoading());
  final result = await repository.login(...);
  result.fold(
    (failure) => emit(AuthFailure(failure.message)),
    (user) => emit(AuthSuccess(user)),
  );
});
```

### Repository模式
```dart
// 接口定义 (domain/repositories/)
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}

// 实现 (data/repositories/)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  
  @override
  Future<Either<Failure, User>> login(email, password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## 错误处理

### 异常定义
```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, [this.statusCode]);
}
```

### Failure定义
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
```

## 本地存储

### Token存储
```dart
// 使用 flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
final token = await storage.read(key: 'auth_token');
```

### 用户偏好
```dart
// 使用 shared_preferences
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('dark_mode', true);
final isDark = prefs.getBool('dark_mode') ?? false;
```

## API请求

### Dio客户端配置
```dart
class DioClient {
  late Dio dio;
  
  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    
    dio.interceptors.add(AuthInterceptor());
  }
}
```

### 认证拦截器
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(options, handler) async {
    final token = await storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(err, handler) {
    if (err.response?.statusCode == 401) {
      // 清除登录状态
    }
    handler.next(err);
  }
}
```

## 性能优化

### Widget优化
- ✅ 使用 `const` 构造函数
- ✅ 使用 `ListView.builder` 懒加载
- ✅ 提取独立Widget减少重建范围
- ✅ 使用 `BlocSelector` 精确监听

### 图片优化
- ✅ 使用 `cached_network_image` 缓存
- ✅ 使用适当分辨率
- ✅ 添加占位图

## 测试规范

### 单元测试
```dart
test('login success', () async {
  when(mockRepo.login(any, any)).thenAnswer(
    (_) async => Right(testUser),
  );
  
  final result = await useCase.call(email: 'test@test.com', password: '123456');
  
  expect(result, isA<Right>());
});
```

### BLoC测试
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () => authBloc,
  act: (bloc) => bloc.add(LoginRequested('email', 'password')),
  expect: () => [AuthLoading(), AuthSuccess(testUser)],
);
```

## 项目配置

### pubspec.yaml要点
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dio: ^5.4.0
  dartz: ^0.10.1
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  equatable: ^2.0.5
```

### 代码检查
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
```

## 常用命令

```bash
# 依赖管理
flutter pub get
flutter pub upgrade

# 代码生成
flutter pub run build_runner build

# 代码检查
flutter analyze

# 测试
flutter test

# 构建
flutter build apk --release
flutter build windows --release
```

---
**版本**: 1.1.0 | **更新**: 2026-01-06
