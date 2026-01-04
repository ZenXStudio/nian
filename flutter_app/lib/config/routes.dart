import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/secure_storage_helper.dart';

/// 路由路径常量
class AppRoutes {
  // 认证相关
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // 主导航
  static const String home = '/home';
  static const String methods = '/methods';
  static const String myMethods = '/my-methods';
  static const String practice = '/practice';
  static const String profile = '/profile';
  
  // 方法详情
  static const String methodDetail = '/method/:id';
  static String methodDetailPath(int id) => '/method/$id';
  
  // 练习记录
  static const String practiceRecord = '/practice/record/:id';
  static String practiceRecordPath(int id) => '/practice/record/$id';
  
  // 设置
  static const String settings = '/settings';
  static const String about = '/about';
}

/// 路由配置
class AppRouter {
  final SecureStorageHelper _secureStorage;
  
  AppRouter(this._secureStorage);
  
  /// 创建GoRouter实例
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: _routes,
    redirect: _handleRedirect,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );
  
  /// 路由定义
  List<RouteBase> get _routes => [
    // 启动页
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const _PlaceholderPage(title: 'Splash'),
    ),
    
    // 登录页
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const _PlaceholderPage(title: 'Login'),
    ),
    
    // 注册页
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const _PlaceholderPage(title: 'Register'),
    ),
    
    // 主页
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _PlaceholderPage(title: 'Home'),
    ),
    
    // 方法列表
    GoRoute(
      path: AppRoutes.methods,
      builder: (context, state) => const _PlaceholderPage(title: 'Methods'),
    ),
    
    // 方法详情
    GoRoute(
      path: AppRoutes.methodDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return _PlaceholderPage(title: 'Method Detail: $id');
      },
    ),
    
    // 个人方法库
    GoRoute(
      path: AppRoutes.myMethods,
      builder: (context, state) => const _PlaceholderPage(title: 'My Methods'),
    ),
    
    // 练习
    GoRoute(
      path: AppRoutes.practice,
      builder: (context, state) => const _PlaceholderPage(title: 'Practice'),
    ),
    
    // 练习记录详情
    GoRoute(
      path: AppRoutes.practiceRecord,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return _PlaceholderPage(title: 'Practice Record: $id');
      },
    ),
    
    // 个人中心
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const _PlaceholderPage(title: 'Profile'),
    ),
    
    // 设置
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const _PlaceholderPage(title: 'Settings'),
    ),
    
    // 关于
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const _PlaceholderPage(title: 'About'),
    ),
  ];
  
  /// 路由守卫 - 处理重定向逻辑
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = await _secureStorage.hasAuthToken();
    final isGoingToAuth = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;
    final isOnSplash = state.matchedLocation == AppRoutes.splash;
    
    // 如果在启动页，不做重定向
    if (isOnSplash) {
      return null;
    }
    
    // 如果未登录且不在认证页面，跳转到登录页
    if (!isLoggedIn && !isGoingToAuth) {
      return AppRoutes.login;
    }
    
    // 如果已登录且在认证页面，跳转到主页
    if (isLoggedIn && isGoingToAuth) {
      return AppRoutes.home;
    }
    
    return null;
  }
}

/// 占位页面 - 用于尚未实现的页面
class _PlaceholderPage extends StatelessWidget {
  final String title;
  
  const _PlaceholderPage({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$title 页面',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '此页面正在开发中',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 错误页面
class _ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const _ErrorPage({this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错误'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面加载失败',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const _PlaceholderPage(title: 'Register'),
    ),
    
    // 主页
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _PlaceholderPage(title: 'Home'),
    ),
    
    // 方法列表
    GoRoute(
      path: AppRoutes.methods,
      builder: (context, state) => const _PlaceholderPage(title: 'Methods'),
    ),
    
    // 方法详情
    GoRoute(
      path: AppRoutes.methodDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return _PlaceholderPage(title: 'Method Detail: $id');
      },
    ),
    
    // 个人方法库
    GoRoute(
      path: AppRoutes.myMethods,
      builder: (context, state) => const _PlaceholderPage(title: 'My Methods'),
    ),
    
    // 练习
    GoRoute(
      path: AppRoutes.practice,
      builder: (context, state) => const _PlaceholderPage(title: 'Practice'),
    ),
    
    // 练习记录详情
    GoRoute(
      path: AppRoutes.practiceRecord,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return _PlaceholderPage(title: 'Practice Record: $id');
      },
    ),
    
    // 个人中心
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const _PlaceholderPage(title: 'Profile'),
    ),
    
    // 设置
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const _PlaceholderPage(title: 'Settings'),
    ),
    
    // 关于
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const _PlaceholderPage(title: 'About'),
    ),
  ];
  
  /// 路由守卫 - 处理重定向逻辑
  Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = await _secureStorage.hasAuthToken();
    final isGoingToAuth = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;
    final isOnSplash = state.matchedLocation == AppRoutes.splash;
    
    // 如果在启动页，不做重定向
    if (isOnSplash) {
      return null;
    }
    
    // 如果未登录且不在认证页面，跳转到登录页
    if (!isLoggedIn && !isGoingToAuth) {
      return AppRoutes.login;
    }
    
    // 如果已登录且在认证页面，跳转到主页
    if (isLoggedIn && isGoingToAuth) {
      return AppRoutes.home;
    }
    
    return null;
  }
}

/// 占位页面 - 用于尚未实现的页面
class _PlaceholderPage extends StatelessWidget {
  final String title;
  
  const _PlaceholderPage({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$title 页面',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '此页面正在开发中',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 错误页面
class _ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const _ErrorPage({this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错误'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面加载失败',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
