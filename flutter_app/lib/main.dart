import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/config/theme.dart';
import 'package:mental_app/config/routes.dart';
import 'package:mental_app/data/repositories/auth_repository.dart';
import 'package:mental_app/data/repositories/method_repository.dart';
import 'package:mental_app/data/repositories/practice_repository.dart';
import 'package:mental_app/data/api/api_client.dart';
import 'package:mental_app/blocs/auth/auth_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化 API 客户端
    final apiClient = ApiClient();
    
    // 初始化仓库
    final authRepository = AuthRepository(apiClient);
    final methodRepository = MethodRepository(apiClient);
    final practiceRepository = PracticeRepository(apiClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: methodRepository),
        RepositoryProvider.value(value: practiceRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: authRepository),
        child: MaterialApp(
          title: '心理自助应用',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/config/theme.dart';
import 'package:mental_app/config/routes.dart';
import 'package:mental_app/data/repositories/auth_repository.dart';
import 'package:mental_app/data/repositories/method_repository.dart';
import 'package:mental_app/data/repositories/practice_repository.dart';
import 'package:mental_app/data/api/api_client.dart';
import 'package:mental_app/blocs/auth/auth_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化 API 客户端
    final apiClient = ApiClient();
    
    // 初始化仓库
    final authRepository = AuthRepository(apiClient);
    final methodRepository = MethodRepository(apiClient);
    final practiceRepository = PracticeRepository(apiClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: methodRepository),
        RepositoryProvider.value(value: practiceRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository: authRepository),
        child: MaterialApp(
          title: '心理自助应用',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
