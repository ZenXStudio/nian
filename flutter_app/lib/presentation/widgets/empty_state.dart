import 'package:flutter/material.dart';

/// 空状态组件
/// 
/// 用于显示无数据时的占位界面
class EmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionButtonText;
  
  const EmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon,
    this.onAction,
    this.actionButtonText,
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
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(actionButtonText ?? '开始'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 搜索无结果组件
class NoSearchResults extends StatelessWidget {
  final String? searchTerm;
  final VoidCallback? onClear;
  
  const NoSearchResults({
    super.key,
    this.searchTerm,
    this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    String message = '未找到相关内容';
    String? description;
    
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      message = '未找到 "$searchTerm" 的相关结果';
      description = '尝试使用其他关键词搜索';
    }
    
    return EmptyState(
      message: message,
      description: description,
      icon: Icons.search_off,
      onAction: onClear,
      actionButtonText: '清除搜索',
    );
  }
}

/// 无方法数据组件
class NoMethodsState extends StatelessWidget {
  final VoidCallback? onBrowse;
  
  const NoMethodsState({
    super.key,
    this.onBrowse,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: '暂无方法',
      description: '探索并添加您感兴趣的心理自助方法',
      icon: Icons.psychology_outlined,
      onAction: onBrowse,
      actionButtonText: '浏览方法',
    );
  }
}

/// 无练习记录组件
class NoPracticeRecordsState extends StatelessWidget {
  final VoidCallback? onStartPractice;
  
  const NoPracticeRecordsState({
    super.key,
    this.onStartPractice,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: '暂无练习记录',
      description: '开始您的第一次练习吧',
      icon: Icons.self_improvement,
      onAction: onStartPractice,
      actionButtonText: '开始练习',
    );
  }
}

/// 收藏夹空状态
class NoFavoritesState extends StatelessWidget {
  final VoidCallback? onBrowse;
  
  const NoFavoritesState({
    super.key,
    this.onBrowse,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: '暂无收藏',
      description: '收藏您喜欢的方法，方便随时练习',
      icon: Icons.favorite_border,
      onAction: onBrowse,
      actionButtonText: '浏览方法',
    );
  }
}
