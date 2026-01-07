import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/user_method_remote_data_source.dart';
import 'package:mental_app/data/repositories/user_method_repository_impl.dart';
import 'package:mental_app/presentation/user_methods/bloc/user_method_list_bloc.dart';
import 'package:mental_app/presentation/user_methods/bloc/user_method_list_event.dart';
import 'package:mental_app/presentation/user_methods/bloc/user_method_list_state.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';
import 'package:mental_app/presentation/widgets/error_widget.dart' as app_error;
import 'package:mental_app/domain/entities/user_method.dart';

/// 个人方法库列表页
class UserMethodListPage extends StatelessWidget {
  const UserMethodListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // 初始化依赖
        final dioClient = DioClient();
        final remoteDataSource = UserMethodRemoteDataSource(dioClient);
        final repository =
            UserMethodRepositoryImpl(remoteDataSource: remoteDataSource);

        return UserMethodListBloc(userMethodRepository: repository)
          ..add(const LoadUserMethods());
      },
      child: const _UserMethodListView(),
    );
  }
}

class _UserMethodListView extends StatefulWidget {
  const _UserMethodListView();

  @override
  State<_UserMethodListView> createState() => _UserMethodListViewState();
}

class _UserMethodListViewState extends State<_UserMethodListView> {
  String _selectedFilter = '全部';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的方法'),
      ),
      body: Column(
        children: [
          // 筛选选项
          _buildFilterTabs(),

          // 方法列表
          Expanded(
            child: BlocConsumer<UserMethodListBloc, UserMethodListState>(
              listener: (context, state) {
                if (state is UserMethodActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserMethodListLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is UserMethodListError) {
                  return Center(
                    child: app_error.AppErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<UserMethodListBloc>()
                            .add(const RefreshUserMethods());
                      },
                    ),
                  );
                }

                if (state is UserMethodListLoaded ||
                    state is UserMethodActionSuccess) {
                  var methods = state is UserMethodListLoaded
                      ? state.methods
                      : (state as UserMethodActionSuccess).methods;

                  // 应用收藏筛选
                  if (_showFavoritesOnly) {
                    methods = methods.where((m) => m.isFavorite).toList();
                  }

                  if (methods.isEmpty) {
                    return const EmptyState(
                      icon: Icons.bookmark_border,
                      message: '还没有添加方法\n去发现感兴趣的方法吧',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<UserMethodListBloc>()
                          .add(const RefreshUserMethods());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: methods.length,
                      itemBuilder: (context, index) {
                        return _buildUserMethodCard(methods[index]);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      // 添加按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 跳转到方法发现页面（首页的第一个Tab）
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.add),
        label: const Text('添加方法'),
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterTabs() {
    final filters = ['全部', '收藏', '焦虑缓解', '睡眠改善', '情绪管理'];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });

                  // 触发筛选
                  String? category;
                  if (filter == '焦虑缓解') category = 'anxiety';
                  if (filter == '睡眠改善') category = 'sleep';
                  if (filter == '情绪管理') category = 'mood';
                  if (filter == '收藏') {
                    // 收藏筛选在客户端实现
                    setState(() {
                      _showFavoritesOnly = true;
                    });
                    return;
                  } else {
                    setState(() {
                      _showFavoritesOnly = false;
                    });
                  }

                  context
                      .read<UserMethodListBloc>()
                      .add(FilterUserMethodsByCategory(category));
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  /// 构建个人方法卡片
  Widget _buildUserMethodCard(UserMethod userMethod) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // 跳转到方法详情页
          Navigator.pushNamed(
            context,
            '/method-detail',
            arguments: userMethod.methodId,
          );
        },
        onLongPress: () {
          _showDeleteConfirmDialog(userMethod);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和收藏按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      userMethod.method.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      userMethod.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: userMethod.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      context
                          .read<UserMethodListBloc>()
                          .add(ToggleFavorite(userMethod.id));
                    },
                  ),
                ],
              ),

              // 个人目标
              if (userMethod.personalGoal != null &&
                  userMethod.personalGoal!.isNotEmpty) ..[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag,
                          size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '我的目标：${userMethod.personalGoal}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // 练习统计
              Row(
                children: [
                  _buildStatItem(
                      Icons.check_circle_outline, '练习', '${userMethod.practiceCount}次'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.calendar_today, '添加时间',
                      _formatDate(userMethod.addedAt)),
                ],
              ),

              const SizedBox(height: 12),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showEditGoalDialog(userMethod);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('编辑目标'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/practice-create',
                          arguments: userMethod.id,
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('开始练习'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return '今天';
    if (difference == 1) return '昨天';
    if (difference < 7) return '$difference天前';
    return '${date.month}/${date.day}';
  }

  /// 显示编辑目标对话框
  void _showEditGoalDialog(UserMethod userMethod) {
    final controller =
        TextEditingController(text: userMethod.personalGoal ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('编辑个人目标'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            labelText: '个人目标',
            hintText: '例如：缓解焦虑，改善睡眠质量',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserMethodListBloc>().add(
                    UpdateUserMethodGoal(
                      userMethodId: userMethod.id,
                      goal: controller.text.trim(),
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(UserMethod userMethod) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除方法'),
        content: Text('确定要删除「${userMethod.method.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<UserMethodListBloc>()
                  .add(DeleteUserMethod(userMethod.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
