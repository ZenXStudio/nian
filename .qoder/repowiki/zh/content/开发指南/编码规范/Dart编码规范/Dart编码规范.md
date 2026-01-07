# Dart编码规范

<cite>
**本文档引用文件**   
- [analysis_options.yaml](file://flutter_app/analysis_options.yaml)
- [FLUTTER_DEVELOPMENT_GUIDE.md](file://FLUTTER_DEVELOPMENT_GUIDE.md)
- [main.dart](file://flutter_app/lib/main.dart)
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart)
- [login_page.dart](file://flutter_app/lib/presentation/auth/pages/login_page.dart)
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart)
- [theme.dart](file://flutter_app/lib/config/theme.dart)
- [app_text_field.dart](file://flutter_app/lib/presentation/widgets/app_text_field.dart)
- [validators.dart](file://flutter_app/lib/core/utils/validators.dart)
- [user_model.dart](file://flutter_app/lib/data/models/user_model.dart)
- [exceptions.dart](file://flutter_app/lib/core/error/exceptions.dart)
- [failures.dart](file://flutter_app/lib/core/error/failures.dart)
- [pubspec.yaml](file://flutter_app/pubspec.yaml)
</cite>

## 目录
1. [命名规范](#命名规范)
2. [静态分析规则](#静态分析规则)
3. [代码实践规范](#代码实践规范)
4. [注释规范](#注释规范)
5. [错误处理设计模式](#错误处理设计模式)
6. [常量与配置规范](#常量与配置规范)

## 命名规范

本项目遵循Dart语言的命名约定，确保代码的一致性和可读性。

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件 | snake_case | `user_model.dart` |
| 类 | PascalCase | `UserModel` |
| 变量/方法 | camelCase | `getUserById` |
| 常量 | lowerCamelCase | `apiBaseUrl` |
| 私有成员 | 前缀下划线 | `_privateMethod` |

文件命名采用snake_case风格，如`auth_repository_impl.dart`、`app_button.dart`等。类名使用PascalCase，如`AuthRepositoryImpl`、`AppButton`等。变量和方法名使用camelCase，如`getUserById`、`buildHeader`等。常量命名推荐使用lowerCamelCase，如`apiBaseUrl`，也可使用UPPER_CASE。

**Section sources**
- [FLUTTER_DEVELOPMENT_GUIDE.md](file://FLUTTER_DEVELOPMENT_GUIDE.md#L3-L11)
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart#L6)
- [user_model.dart](file://flutter_app/lib/data/models/user_model.dart#L6)

## 静态分析规则

`analysis_options.yaml`文件配置了项目的静态分析规则，通过`flutter_lints`包引入推荐的lint规则，并可根据项目需求进行定制。

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
    prefer_final_locals: true
    prefer_single_quotes: true
```

启用的关键lint规则包括：
- `avoid_print`: 禁止使用print语句，鼓励使用日志系统
- `prefer_const_constructors`: 优先使用const构造函数以提高性能
- `prefer_final_locals`: 局部变量优先声明为final，促进不可变性
- `prefer_single_quotes`: 字符串优先使用单引号

这些规则通过`flutter analyze`命令执行静态分析，帮助维护代码质量和一致性。

**Section sources**
- [analysis_options.yaml](file://flutter_app/analysis_options.yaml#L1-L29)
- [FLUTTER_DEVELOPMENT_GUIDE.md](file://FLUTTER_DEVELOPMENT_GUIDE.md#L209-L217)

## 代码实践规范

结合`FLUTTER_DEVELOPMENT_GUIDE.md`中的实践建议，本项目遵循以下代码实践规范。

### const构造函数的使用

优先使用const构造函数创建Widget，以提高性能和减少重建：

```dart
const SizedBox(height: 16),
const Text('Hello World'),
```

在`main.dart`中，`MyApp`类的构造函数使用了`const`关键字，`MaterialApp`的路由配置也使用了`const`。

### 可复用Widget的提取

将复杂的UI组件提取为独立的Widget方法，减少嵌套层级，提高可维护性：

```dart
Widget _buildHeader() {
  return Column(...);
}
```

项目中的`app_button.dart`和`app_text_field.dart`文件定义了可复用的UI组件，如`AppButton`和`AppTextField`。

### 异步编程模式

优先使用async/await模式处理异步操作，使代码更清晰易读：

```dart
Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(const AuthLoading());
  final result = await authRepository.login(
    email: event.email,
    password: event.password,
  );
  // 处理结果
}
```

在BLoC模式中，事件处理器使用async/await处理异步业务逻辑。

**Section sources**
- [main.dart](file://flutter_app/lib/main.dart#L25)
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart#L37-L52)
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart#L6)
- [app_text_field.dart](file://flutter_app/lib/presentation/widgets/app_text_field.dart#L7)

## 注释规范

本项目区分文档注释（///）与单行注释（//）的使用场景。

### 文档注释（///）

用于类、方法、属性等公共API的文档说明，遵循Dart文档注释规范：

```dart
/// 应用通用按钮组件
/// 
/// 提供统一的按钮样式和行为
class AppButton extends StatelessWidget {
  // ...
}
```

文档注释包含简短描述和详细说明，使用`///`开头，支持Markdown格式。

### 单行注释（//）

用于代码内部的逻辑说明、调试标记或临时注释：

```dart
// 初始化核心组件
final dioClient = DioClient();
final secureStorage = SecureStorageHelper();

// 处理需要参数的路由
if (settings.name == '/method-detail') {
  // ...
}
```

单行注释用于解释代码的意图或复杂逻辑，帮助其他开发者理解代码。

**Section sources**
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart#L3-L5)
- [main.dart](file://flutter_app/lib/main.dart#L29-L30)
- [login_page.dart](file://flutter_app/lib/presentation/auth/pages/login_page.dart#L9)

## 错误处理设计模式

项目采用分层的错误处理设计模式，区分异常（Exception）和失败（Failure）。

### 异常与失败的区分

- **异常（Exception）**: 在数据层（data layer）抛出，表示技术性错误
- **失败（Failure）**: 在领域层（domain layer）使用，表示业务性错误

这种分离遵循Clean Architecture原则，使业务逻辑不依赖于具体的技术实现。

### 异常定义

在`core/error/exceptions.dart`中定义了各种异常类型，继承自`AppException`：

```dart
/// 服务器异常
class ServerException extends AppException {
  final int? statusCode;
  ServerException(super.message, {this.statusCode, super.code});
}
```

异常用于表示网络、服务器、缓存等技术层面的问题。

### 失败定义

在`core/error/failures.dart`中定义了各种失败类型，继承自`Failure`：

```dart
/// 服务器失败
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode, super.code});
}
```

失败用于在业务逻辑中传递错误信息，与具体的异常实现解耦。

### 错误处理流程

在Repository实现中，捕获异常并转换为对应的失败：

```dart
@override
Future<Either<Failure, User>> login({
  required String email,
  required String password,
}) async {
  try {
    final result = await remoteDataSource.login(email, password);
    // ...
    return Right(user);
  } on AuthenticationException catch (e) {
    return Left(AuthenticationFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message, statusCode: e.statusCode));
  } catch (e) {
    return Left(UnknownFailure('登录失败: ${e.toString()}'));
  }
}
```

使用`Either<Failure, Data>`模式返回结果，明确区分成功和失败情况。

**Section sources**
- [exceptions.dart](file://flutter_app/lib/core/error/exceptions.dart#L1-L110)
- [failures.dart](file://flutter_app/lib/core/error/failures.dart#L1-L157)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart#L20-L47)

## 常量与配置规范

项目中的常量和配置遵循统一的命名和组织规范。

### 主题常量

在`config/theme.dart`中定义了应用的主题常量：

```dart
class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  
  // 浅色主题和深色主题
  static ThemeData lightTheme = ThemeData(...);
  static ThemeData darkTheme = ThemeData(...);
}
```

主题常量使用`static const`定义，确保编译时常量和性能优化。

### 验证器

在`core/utils/validators.dart`中提供了常用的输入验证器：

```dart
class Validators {
  /// 验证邮箱格式
  static String? validateEmail(String? value) {
    // ...
  }
  
  /// 验证密码强度
  static String? validatePassword(String? value, {int minLength = 6}) {
    // ...
  }
}
```

验证器作为工具类提供静态方法，便于在表单验证中复用。

**Section sources**
- [theme.dart](file://flutter_app/lib/config/theme.dart#L3-L77)
- [validators.dart](file://flutter_app/lib/core/utils/validators.dart#L4-L165)