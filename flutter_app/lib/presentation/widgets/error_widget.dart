import 'package:flutter/material.dart';

/// 错误显示组件
/// 
/// 用于显示错误信息和重试操作
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonText;
  
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryButtonText,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? '重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: '网络连接失败\n请检查您的网络设置',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// 服务器错误组件
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: '服务器错误\n请稍后再试',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}

/// 未授权错误组件
class UnauthorizedErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;
  
  const UnauthorizedErrorWidget({
    super.key,
    this.onLogin,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: '您尚未登录或登录已过期\n请重新登录',
      icon: Icons.lock_outline,
      onRetry: onLogin,
      retryButtonText: '去登录',
    );
  }
}

/// 错误提示横幅
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.error,
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
