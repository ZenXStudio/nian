import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// 应用日志工具类
/// 封装logger包，提供统一的日志记录接口
class AppLogger {
  static Logger? _logger;
  static bool _isInitialized = false;
  
  /// 日志级别
  static Level _level = kDebugMode ? Level.debug : Level.warning;
  
  /// 初始化日志系统
  /// 
  /// [level] 日志级别，默认根据运行模式自动设置
  /// - Debug模式: Level.debug
  /// - Release模式: Level.warning
  static void initialize({Level? level}) {
    if (_isInitialized) return;
    
    if (level != null) {
      _level = level;
    }
    
    _logger = Logger(
      filter: _AppLogFilter(_level),
      printer: _AppLogPrinter(),
      output: _AppLogOutput(),
    );
    
    _isInitialized = true;
  }
  
  /// 获取Logger实例
  static Logger get instance {
    if (!_isInitialized) {
      initialize();
    }
    return _logger!;
  }
  
  /// 调试日志 - 用于开发调试
  /// 
  /// [message] 日志消息
  /// [error] 错误对象（可选）
  /// [stackTrace] 堆栈跟踪（可选）
  static void debug(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// 信息日志 - 用于记录重要操作
  /// 
  /// [message] 日志消息
  /// [error] 错误对象（可选）
  /// [stackTrace] 堆栈跟踪（可选）
  static void info(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// 警告日志 - 用于记录潜在问题
  /// 
  /// [message] 日志消息
  /// [error] 错误对象（可选）
  /// [stackTrace] 堆栈跟踪（可选）
  static void warning(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// 错误日志 - 用于记录可恢复的错误
  /// 
  /// [message] 日志消息
  /// [error] 错误对象（可选）
  /// [stackTrace] 堆栈跟踪（可选）
  static void error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// 严重错误日志 - 用于记录严重错误
  /// 
  /// [message] 日志消息
  /// [error] 错误对象（可选）
  /// [stackTrace] 堆栈跟踪（可选）
  static void fatal(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }
  
  /// 网络日志 - 专用于记录网络请求
  /// 
  /// [method] HTTP方法
  /// [url] 请求URL
  /// [statusCode] 响应状态码（可选）
  /// [duration] 请求耗时（可选）
  static void network(
    String method,
    String url, {
    int? statusCode,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    buffer.write('[NETWORK] $method $url');
    
    if (statusCode != null) {
      buffer.write(' -> $statusCode');
    }
    
    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }
    
    info(buffer.toString());
  }
  
  /// BLoC事件日志 - 用于记录BLoC事件
  /// 
  /// [blocName] BLoC名称
  /// [eventName] 事件名称
  static void blocEvent(String blocName, String eventName) {
    debug('[BLOC] $blocName -> Event: $eventName');
  }
  
  /// BLoC状态日志 - 用于记录BLoC状态变化
  /// 
  /// [blocName] BLoC名称
  /// [stateName] 状态名称
  static void blocState(String blocName, String stateName) {
    debug('[BLOC] $blocName -> State: $stateName');
  }
  
  /// Repository日志 - 用于记录数据仓库操作
  /// 
  /// [repositoryName] 仓库名称
  /// [operation] 操作名称
  /// [result] 操作结果（可选）
  static void repository(
    String repositoryName,
    String operation, {
    String? result,
  }) {
    final message = result != null
        ? '[REPOSITORY] $repositoryName.$operation -> $result'
        : '[REPOSITORY] $repositoryName.$operation';
    
    debug(message);
  }
  
  /// 性能日志 - 用于记录性能指标
  /// 
  /// [operation] 操作名称
  /// [duration] 耗时
  static void performance(String operation, Duration duration) {
    final ms = duration.inMilliseconds;
    final level = ms > 1000 ? 'SLOW' : 'OK';
    info('[PERFORMANCE] $operation: ${ms}ms ($level)');
  }
  
  /// 设置日志级别
  static void setLevel(Level level) {
    _level = level;
    if (_isInitialized) {
      _logger = Logger(
        filter: _AppLogFilter(level),
        printer: _AppLogPrinter(),
        output: _AppLogOutput(),
      );
    }
  }
}

/// 自定义日志过滤器
class _AppLogFilter extends LogFilter {
  final Level level;
  
  _AppLogFilter(this.level);
  
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level.index;
  }
}

/// 自定义日志打印器
class _AppLogPrinter extends LogPrinter {
  static final levelEmojis = {
    Level.debug: '🐛',
    Level.info: 'ℹ️',
    Level.warning: '⚠️',
    Level.error: '❌',
    Level.fatal: '💀',
  };
  
  static final levelNames = {
    Level.debug: 'DEBUG',
    Level.info: 'INFO',
    Level.warning: 'WARN',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };
  
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level]!;
    final emoji = levelEmojis[event.level] ?? '';
    final levelName = levelNames[event.level] ?? '';
    final message = event.message;
    final time = DateTime.now();
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    
    final output = <String>[];
    
    // 主消息
    output.add(color('$emoji [$levelName] [$timeStr] $message'));
    
    // 错误信息
    if (event.error != null) {
      output.add(color('Error: ${event.error}'));
    }
    
    // 堆栈跟踪（仅在debug模式和error/fatal级别显示）
    if (event.stackTrace != null && 
        kDebugMode && 
        (event.level == Level.error || event.level == Level.fatal)) {
      output.add(color('StackTrace:'));
      final stackLines = event.stackTrace.toString().split('\n');
      for (var line in stackLines.take(5)) {
        output.add(color('  $line'));
      }
    }
    
    return output;
  }
}

/// 自定义日志输出器
class _AppLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // 在debug模式下输出到控制台
    if (kDebugMode) {
      for (var line in event.lines) {
        // ignore: avoid_print
        print(line);
      }
    }
    
    // 在release模式下可以将日志发送到远程服务器
    // TODO: 实现远程日志收集
  }
}

/// 日志级别扩展
extension LevelExtension on Level {
  /// 获取级别名称
  String get name {
    switch (this) {
      case Level.trace:
        return 'TRACE';
      case Level.debug:
        return 'DEBUG';
      case Level.info:
        return 'INFO';
      case Level.warning:
        return 'WARNING';
      case Level.error:
        return 'ERROR';
      case Level.fatal:
        return 'FATAL';
      default:
        return 'UNKNOWN';
    }
  }
}
