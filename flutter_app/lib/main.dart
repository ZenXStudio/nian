import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/config/theme.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/core/storage/secure_storage_helper.dart';
import 'package:mental_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:mental_app/data/repositories/auth_repository_impl.dart';
import 'package:mental_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:mental_app/presentation/auth/bloc/auth_event.dart';
import 'package:mental_app/presentation/auth/pages/splash_page.dart';
import 'package:mental_app/presentation/auth/pages/login_page.dart';
import 'package:mental_app/presentation/auth/pages/register_page.dart';
import 'package:mental_app/presentation/home/main_page.dart';
import 'package:mental_app/presentation/methods/pages/method_detail_page.dart';
import 'package:mental_app/presentation/methods/pages/method_search_page.dart';
import 'package:mental_app/presentation/practice/pages/practice_record_create_page.dart';
import 'package:mental_app/presentation/practice/pages/practice_stats_page.dart';
import 'package:mental_app/presentation/profile/pages/change_password_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化核心组件
    final dioClient = DioClient();
    final secureStorage = SecureStorageHelper();
    
    // 初始化数据源
    final authDataSource = AuthRemoteDataSource(dioClient);
    
    // 初始化Repository
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authDataSource,
      secureStorage: secureStorage,
    );

    return BlocProvider(
      create: (context) => AuthBloc(authRepository: authRepository)
        ..add(const AppStarted()),
      child: MaterialApp(
        title: '心理自助应用',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MainPage(),
        },
        onGenerateRoute: (settings) {
          // 处理需要参数的路由
          if (settings.name == '/method-detail') {
            final methodId = settings.arguments as int?;
            if (methodId != null) {
              return MaterialPageRoute(
                builder: (context) => MethodDetailPage(methodId: methodId),
              );
            }
          }

          // 练习记录创建页面
          if (settings.name == '/practice-create') {
            final userMethodId = settings.arguments as int?;
            return MaterialPageRoute(
              builder: (context) =>
                  PracticeRecordCreatePage(userMethodId: userMethodId),
            );
          }

          // 练习统计页面
          if (settings.name == '/practice-stats') {
            return MaterialPageRoute(
              builder: (context) => const PracticeStatsPage(),
            );
          }

          // 修改密码页面
          if (settings.name == '/change-password') {
            return MaterialPageRoute(
              builder: (context) => const ChangePasswordPage(),
            );
          }

          // 方法搜索页面
          if (settings.name == '/method-search') {
            return MaterialPageRoute(
              builder: (context) => const MethodSearchPage(),
            );
          }

          return null;
        },
      ),
    );
  }
}
