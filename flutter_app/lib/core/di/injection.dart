import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// GetIt服务定位器实例
final getIt = GetIt.instance;

/// 初始化依赖注入
/// 
/// 在应用启动时调用，配置所有依赖项
/// 
/// [environment] 环境配置，默认为生产环境
/// 可选值：
/// - Environment.prod: 生产环境
/// - Environment.dev: 开发环境
/// - Environment.test: 测试环境
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String environment = Environment.prod}) async {
  await getIt.init(environment: environment);
}

/// 重置依赖注入（主要用于测试）
Future<void> resetDependencies() async {
  await getIt.reset();
}
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// GetIt服务定位器实例
final getIt = GetIt.instance;

/// 初始化依赖注入
/// 
/// 在应用启动时调用，配置所有依赖项
/// 
/// [environment] 环境配置，默认为生产环境
/// 可选值：
/// - Environment.prod: 生产环境
/// - Environment.dev: 开发环境
/// - Environment.test: 测试环境
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String environment = Environment.prod}) async {
  await getIt.init(environment: environment);
}

/// 重置依赖注入（主要用于测试）
Future<void> resetDependencies() async {
  await getIt.reset();
}
