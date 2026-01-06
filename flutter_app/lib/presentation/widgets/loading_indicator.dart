import 'package:flutter/material.dart';

/// 加载指示器组件
/// 
/// 提供统一的加载动画样式
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 全屏加载覆盖层
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingIndicator(message: message),
          ),
      ],
    );
  }
}

/// 线性加载指示器
class LinearLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final Color? color;
  
  const LinearLoadingIndicator({
    super.key,
    required this.isLoading,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }
    
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}

/// Shimmer加载占位符
class ShimmerPlaceholder extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  const ShimmerPlaceholder({
    super.key,
    required this.child,
    required this.isLoading,
  });
  
  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 简单的骨架屏占位符
class SkeletonPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const SkeletonPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}
