# Flutter移动端集成

<cite>
**本文档引用文件**   
- [api_client.dart](file://flutter_app/lib/data/api/api_client.dart)
- [api_constants.dart](file://flutter_app/lib/config/api_constants.dart)
- [dio_client.dart](file://flutter_app/lib/core/network/dio_client.dart)
- [secure_storage_helper.dart](file://flutter_app/lib/core/storage/secure_storage_helper.dart)
- [secure_storage.dart](file://flutter_app/lib/data/storage/secure_storage.dart)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart)
- [auth_repository.dart](file://flutter_app/lib/domain/repositories/auth_repository.dart)
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart)
- [routes.dart](file://flutter_app/lib/config/routes.dart)
- [pubspec.yaml](file://flutter_app/pubspec.yaml)
- [FLUTTER_SETUP_GUIDE.md](file://FLUTTER_SETUP_GUIDE.md)
</cite>

## 目录
1. [项目结构](#项目结构)
2. [API客户端封装](#api客户端封装)
3. [端点定义与环境配置](#端点定义与环境配置)
4. [Dio客户端配置](#dio客户端配置)
5. [安全存储机制](#安全存储机制)
6. [认证数据流](#认证数据流)
7. [API调用示例](#api调用示例)
8. [路由守卫与导航](#路由守卫与导航)
9. [依赖关系图](#依赖关系图)

## 项目结构

Flutter应用采用分层架构设计，将代码组织为清晰的目录结构，遵循关注点分离原则。核心目录包括`lib/config`（配置）、`lib/core`（核心功能）、`lib/data`（数据层）、`lib/domain`（领域层）和`lib/presentation`（表现层）。

```mermaid
graph TD
subgraph "表现层"
A[presentation/auth/bloc]
B[presentation/auth/pages]
end
subgraph "领域层"
C[domain/repositories]
D[domain/entities]
end
subgraph "数据层"
E[data/datasources/remote]
F[data/repositories]
G[data/models]
end
subgraph "核心层"
H[core/network]
I[core/storage]
J[core/error]
end
A --> C
C --> F
F --> E
H --> E
I --> F
J --> F
```

**图示来源**
- [项目结构](file://flutter_app)

**本节来源**
- [项目结构](file://flutter_app)

## API客户端封装

`api_client.dart`文件实现了基于Dio的API客户端封装，提供统一的HTTP请求接口和自动认证头注入功能。该类通过`SecureStorage`获取JWT令牌，并在每个请求中自动添加Authorization头。

```mermaid
classDiagram
class ApiClient {
-Dio _dio
-SecureStorage _storage
+ApiClient()
+get dio
+get(path, queryParameters, options)
+post(path, data, queryParameters, options)
+put(path, data, queryParameters, options)
+delete(path, data, queryParameters, options)
}
class SecureStorage {
+saveToken(token)
+getToken()
+deleteToken()
+saveUser(userJson)
+getUser()
+deleteUser()
+clearAll()
}
ApiClient --> SecureStorage : "使用"
ApiClient --> Dio : "封装"
```

**图示来源**
- [api_client.dart](file://flutter_app/lib/data/api/api_client.dart#L5-L103)
- [secure_storage.dart](file://flutter_app/lib/data/storage/secure_storage.dart#L4-L45)

**本节来源**
- [api_client.dart](file://flutter_app/lib/data/api/api_client.dart#L5-L103)
- [secure_storage.dart](file://flutter_app/lib/data/storage/secure_storage.dart#L4-L45)

## 端点定义与环境配置

`api_constants.dart`文件集中定义了所有API端点和配置常量，包括基础URL、超时设置和存储键。基础URL通过`String.fromEnvironment`从构建环境注入，支持不同环境下的不同后端地址。

```mermaid
classDiagram
class ApiConstants {
+String baseUrl
+String login
+String register
+String getUserInfo
+String getMethods
+String getMethodDetail
+String getRecommendedMethods
+String getUserMethods
+String addUserMethod
+String removeUserMethod
+String createPractice
+String getPractices
+String getPracticeStats
+int connectTimeout
+int receiveTimeout
+String tokenKey
+String userKey
}
```

**图示来源**
- [api_constants.dart](file://flutter_app/lib/config/api_constants.dart#L1-L36)

**本节来源**
- [api_constants.dart](file://flutter_app/lib/config/api_constants.dart#L1-L36)

## Dio客户端配置

`dio_client.dart`文件提供了更高级的Dio客户端封装，包含多个拦截器用于日志记录、错误处理和认证。该实现使用依赖注入（`@lazySingleton`），确保在整个应用中共享同一个实例。

```mermaid
classDiagram
class DioClient {
-Dio _dio
-FlutterSecureStorage _secureStorage
+DioClient(_secureStorage)
+get dio
+_buildBaseOptions()
+_setupInterceptors()
+updateToken(token)
+clearToken()
}
class _AuthInterceptor {
-FlutterSecureStorage _secureStorage
+onRequest(options, handler)
+onError(err, handler)
}
class _LogInterceptor {
+onRequest(options, handler)
+onResponse(response, handler)
+onError(err, handler)
}
class _ErrorInterceptor {
+onError(err, handler)
+_handleStatusCode(statusCode)
}
DioClient --> _AuthInterceptor : "包含"
DioClient --> _LogInterceptor : "包含"
DioClient --> _ErrorInterceptor : "包含"
DioClient --> FlutterSecureStorage : "使用"
```

**图示来源**
- [dio_client.dart](file://flutter_app/lib/core/network/dio_client.dart#L12-L262)

**本节来源**
- [dio_client.dart](file://flutter_app/lib/core/network/dio_client.dart#L12-L262)

## 安全存储机制

`secure_storage_helper.dart`文件封装了`flutter_secure_storage`插件，提供安全的数据存储功能。该类实现了单例模式，用于存储敏感信息如认证令牌、用户密码和生物识别状态。

```mermaid
classDiagram
class SecureStorageHelper {
-FlutterSecureStorage _storage
+keyAuthToken
+keyRefreshToken
+keyUserPassword
+keyUserEmail
+keyBiometricEnabled
+SecureStorageHelper(_storage)
+write(key, value)
+read(key)
+delete(key)
+containsKey(key)
+deleteAll()
+readAll()
+saveAuthToken(token)
+getAuthToken()
+deleteAuthToken()
+hasAuthToken()
+saveRefreshToken(token)
+getRefreshToken()
+deleteRefreshToken()
+saveUserPassword(password)
+getUserPassword()
+deleteUserPassword()
+saveUserEmail(email)
+getUserEmail()
+deleteUserEmail()
+saveBiometricEnabled(enabled)
+getBiometricEnabled()
+clearAuthData()
+clearUserCredentials()
}
SecureStorageHelper --> FlutterSecureStorage : "使用"
```

**图示来源**
- [secure_storage_helper.dart](file://flutter_app/lib/core/storage/secure_storage_helper.dart#L10-L194)

**本节来源**
- [secure_storage_helper.dart](file://flutter_app/lib/core/storage/secure_storage_helper.dart#L10-L194)

## 认证数据流

认证功能通过BLoC模式实现，从UI事件触发到API调用形成完整数据流。当用户提交登录表单时，事件被发送到`AuthBloc`，由`AuthRepository`协调远程数据源和本地存储。

```mermaid
sequenceDiagram
participant UI as 登录页面
participant Bloc as AuthBloc
participant Repository as AuthRepositoryImpl
participant DataSource as AuthRemoteDataSource
participant Storage as SecureStorageHelper
participant API as 后端API
UI->>Bloc : LoginRequested事件
Bloc->>Repository : login(email, password)
Repository->>DataSource : login(email, password)
DataSource->>API : POST /auth/login
API-->>DataSource : 返回token和用户数据
DataSource-->>Repository : 返回结果
Repository->>Storage : saveAuthToken(token)
Repository-->>Bloc : 返回User
Bloc-->>UI : Authenticated状态
```

**图示来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart#L7-L82)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart#L11-L114)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart#L7-L77)

**本节来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart#L7-L82)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart#L11-L114)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart#L7-L77)

## API调用示例

以下展示了从BLoC触发到Repository调用API的完整流程。以登录功能为例，`AuthBloc`接收`LoginRequested`事件，调用`AuthRepository`的`login`方法，该方法通过`AuthRemoteDataSource`发起网络请求。

```mermaid
flowchart TD
Start([用户点击登录]) --> Validate["验证邮箱和密码"]
Validate --> IsValid{"验证通过?"}
IsValid --> |否| ShowError["显示错误信息"]
IsValid --> |是| Dispatch["分发LoginRequested事件"]
Dispatch --> Bloc["AuthBloc处理事件"]
Bloc --> Repository["调用AuthRepository.login"]
Repository --> DataSource["AuthRemoteDataSource.login"]
DataSource --> API["DioClient.post('/auth/login')"]
API --> Success{"请求成功?"}
Success --> |否| HandleError["处理错误"]
Success --> |是| SaveToken["SecureStorageHelper.saveAuthToken"]
SaveToken --> UpdateState["更新BLoC状态为Authenticated"]
UpdateState --> Navigate["导航到主页"]
HandleError --> ShowError
ShowError --> End([等待用户操作])
Navigate --> End
```

**图示来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart#L36-L52)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart#L21-L36)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart#L13-L22)

**本节来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart#L36-L52)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart#L21-L36)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart#L13-L22)

## 路由守卫与导航

`routes.dart`文件实现了基于GoRouter的路由系统，包含路由守卫功能。通过`_handleRedirect`方法检查用户认证状态，实现自动重定向：未登录用户访问受保护页面时跳转到登录页，已登录用户访问登录页时跳转到主页。

```mermaid
flowchart TD
Start([应用启动]) --> CheckAuth["检查hasAuthToken()"]
CheckAuth --> IsLoggedIn{"已登录?"}
IsLoggedIn --> |否| OnAuthPage{"在认证页面?"}
IsLoggedIn --> |是| OnAuthPage{"在认证页面?"}
OnAuthPage --> |是| NavigateHome["跳转到主页"]
OnAuthPage --> |否| StayOrLogin["保持当前页面或跳转登录"]
StayOrLogin --> |当前为非认证页| RedirectToLogin["跳转到登录页"]
StayOrLogin --> |当前为认证页| Stay["保持在认证页"]
NavigateHome --> End
RedirectToLogin --> End
Stay --> End
```

**图示来源**
- [routes.dart](file://flutter_app/lib/config/routes.dart#L34-L155)

**本节来源**
- [routes.dart](file://flutter_app/lib/config/routes.dart#L34-L155)

## 依赖关系图

整个API集成系统的组件依赖关系如下图所示，展示了从表现层到数据层的完整依赖链。

```mermaid
graph TD
subgraph "表现层"
A[AuthBloc]
B[LoginPage]
end
subgraph "领域层"
C[AuthRepository]
end
subgraph "数据层"
D[AuthRepositoryImpl]
E[AuthRemoteDataSource]
end
subgraph "核心层"
F[DioClient]
G[SecureStorageHelper]
end
subgraph "外部"
H[Dio]
I[FlutterSecureStorage]
end
B --> A
A --> C
C --> D
D --> E
D --> G
E --> F
F --> H
G --> I
```

**图示来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart)
- [auth_repository.dart](file://flutter_app/lib/domain/repositories/auth_repository.dart)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart)
- [dio_client.dart](file://flutter_app/lib/core/network/dio_client.dart)
- [secure_storage_helper.dart](file://flutter_app/lib/core/storage/secure_storage_helper.dart)

**本节来源**
- [auth_bloc.dart](file://flutter_app/lib/presentation/auth/bloc/auth_bloc.dart)
- [auth_repository.dart](file://flutter_app/lib/domain/repositories/auth_repository.dart)
- [auth_repository_impl.dart](file://flutter_app/lib/data/repositories/auth_repository_impl.dart)
- [auth_remote_data_source.dart](file://flutter_app/lib/data/datasources/remote/auth_remote_data_source.dart)
- [dio_client.dart](file://flutter_app/lib/core/network/dio_client.dart)
- [secure_storage_helper.dart](file://flutter_app/lib/core/storage/secure_storage_helper.dart)