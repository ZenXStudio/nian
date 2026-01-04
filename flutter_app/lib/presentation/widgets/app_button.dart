import 'package:flutter/material.dart';

/// 应用通用按钮组件
/// 
/// 提供统一的按钮样式和行为
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonType type;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? padding;
  
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.type = AppButtonType.primary,
    this.icon,
    this.height,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: _getButtonStyle(theme),
      child: _buildButtonChild(theme),
    );
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 48,
        child: button,
      );
    }
    
    return SizedBox(
      height: height ?? 48,
      child: button,
    );
  }
  
  Widget _buildButtonChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.outlined || type == AppButtonType.text
                ? theme.primaryColor
                : Colors.white,
          ),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
  
  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      
      case AppButtonType.outlined:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.primaryColor,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.primaryColor,
              width: 1.5,
            ),
          ),
        );
      
      case AppButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.primaryColor,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      
      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}

/// 按钮类型枚举
enum AppButtonType {
  /// 主要按钮 - 实心
  primary,
  
  /// 次要按钮 - 实心
  secondary,
  
  /// 边框按钮 - 空心有边框
  outlined,
  
  /// 文本按钮 - 无边框
  text,
  
  /// 危险按钮 - 红色
  danger,
}

/// 图标按钮组件
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon, size: size),
      onPressed: onPressed,
      color: color,
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}
", "original_text": null}