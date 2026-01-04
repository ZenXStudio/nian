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
import 'package:mental_app/presentation/home/home_page.dart';

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
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
