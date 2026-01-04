import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/method_remote_data_source.dart';
import 'package:mental_app/data/datasources/remote/user_method_remote_data_source.dart';
import 'package:mental_app/data/repositories/method_repository_impl.dart';
import 'package:mental_app/data/repositories/user_method_repository_impl.dart';
import 'package:mental_app/domain/entities/method.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_bloc.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_state.dart';

/// 方法详情页
class MethodDetailPage extends StatelessWidget {
  final int methodId;

  const MethodDetailPage({
    super.key,
    required this.methodId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dioClient = DioClient();
        final methodDataSource = MethodRemoteDataSource(dioClient);
        final methodRepository = MethodRepositoryImpl(
          remoteDataSource: methodDataSource,
        );
        final userMethodDataSource = UserMethodRemoteDataSource(dioClient);
        final userMethodRepository = UserMethodRepositoryImpl(
          remoteDataSource: userMethodDataSource,
        );
        return MethodDetailBloc(
          methodRepository: methodRepository,
          userMethodRepository: userMethodRepository,
        )..add(LoadMethodDetail(methodId));
      },
      child: const _MethodDetailView(),
    );
  }
}

class _MethodDetailView extends StatefulWidget {
  const _MethodDetailView();

  @override
  State<_MethodDetailView> createState() => _MethodDetailViewState();
}

class _MethodDetailViewState extends State<_MethodDetailView> {
  final _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('方法详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('分享功能开发中...')),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<MethodDetailBloc, MethodDetailState>(
        listener: (context, state) {
          if (state is MethodAddedToLibrary) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已成功添加到个人方法库！'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MethodDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MethodDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MethodDetailLoaded) {
            return _buildMethodDetail(context, state.method);
          } else if (state is MethodDetailError) {
            return _buildErrorView(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<MethodDetailBloc, MethodDetailState>(
        builder: (context, state) {
          if (state is! MethodDetailLoaded) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showAddToLibraryDialog(context, state.method.id),
            icon: const Icon(Icons.add),
            label: const Text('添加到个人库'),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final methodId = (context.widget as Scaffold)
                  .body as BlocConsumer<MethodDetailBloc, MethodDetailState>;
              context.read<MethodDetailBloc>().add(LoadMethodDetail(1));
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodDetail(BuildContext context, Method method) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图片
          if (method.coverImageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                method.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 64),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 方法名称
                Text(
                  method.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // 基本信息
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.category,
                      method.category,
                    ),
                    _buildInfoChip(
                      context,
                      Icons.layers,
                      _getDifficultyText(method.difficulty),
                    ),
                    if (method.durationMinutes != null)
                      _buildInfoChip(
                        context,
                        Icons.schedule,
                        '${method.durationMinutes}分钟',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 分割线
                const Divider(),
                const SizedBox(height: 16),

                // 方法描述
                Text(
                  '方法介绍',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  method.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // 详细内容
                if (method.detailedContent != null) ...[
                  Text(
                    '详细内容',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    method.detailedContent!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],

                // 使用步骤
                if (method.steps != null && method.steps!.isNotEmpty) ...[
                  Text(
                    '使用步骤',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...method.steps!.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            child: Text('${entry.key + 1}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],

                // 注意事项
                if (method.precautions != null && method.precautions!.isNotEmpty) ...[
                  Text(
                    '注意事项',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...method.precautions!.map((precaution) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, size: 20, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              precaution,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],

                // 底部添加空白，避免被FAB遮挡
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '入门';
      case 'intermediate':
        return '中级';
      case 'advanced':
        return '高级';
      default:
        return difficulty;
    }
  }

  /// 显示添加到个人库的对话框
  void _showAddToLibraryDialog(BuildContext context, int methodId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('添加到个人方法库'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('你可以为这个方法设定个人目标（可选）：'),
              const SizedBox(height: 16),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(
                  hintText: '例如：每天练习10分钟',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<MethodDetailBloc>().add(
                      AddMethodToLibrary(
                        methodId: methodId,
                        personalGoal: _goalController.text.isNotEmpty
                            ? _goalController.text
                            : null,
                      ),
                    );
                _goalController.clear();
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}
