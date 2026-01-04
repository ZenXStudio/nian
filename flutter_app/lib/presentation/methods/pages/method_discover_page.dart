import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/presentation/widgets/error_widget.dart' as app_error;
import 'package:mental_app/presentation/methods/bloc/method_list_bloc.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_state.dart';
import 'package:mental_app/domain/entities/method.dart';
import 'package:mental_app/data/repositories/method_repository_impl.dart';
import 'package:mental_app/data/datasources/remote/method_remote_data_source.dart';
import 'package:mental_app/core/network/dio_client.dart';

/// 方法发现页面（首页内容）
class MethodDiscoverPage extends StatelessWidget {
  const MethodDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // 初始化依赖
        final dioClient = DioClient();
        final remoteDataSource = MethodRemoteDataSource(dioClient);
        final repository = MethodRepositoryImpl(remoteDataSource: remoteDataSource);
        
        return MethodListBloc(methodRepository: repository)
          ..add(const LoadMethods());
      },
      child: const _MethodDiscoverView(),
    );
  }
}

class _MethodDiscoverView extends StatefulWidget {
  const _MethodDiscoverView();

  @override
  State<_MethodDiscoverView> createState() => _MethodDiscoverViewState();
}

class _MethodDiscoverViewState extends State<_MethodDiscoverView> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MethodListBloc>().add(const LoadMoreMethods());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心理自助'),
        actions: [
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 跳转到搜索页面
              // Navigator.pushNamed(context, '/method-search');
            },
          ),
          // 通知按钮
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 显示通知
            },
          ),
        ],
      ),
      body: BlocBuilder<MethodListBloc, MethodListState>(
        builder: (context, state) {
          if (state is MethodListLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is MethodListError) {
            return Center(
              child: app_error.AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<MethodListBloc>().add(const RefreshMethods());
                },
              ),
            );
          }

          if (state is MethodListLoaded || state is MethodListLoadingMore) {
            final methods = state is MethodListLoaded
                ? state.methods
                : (state as MethodListLoadingMore).methods;

            if (methods.isEmpty) {
              return const EmptyState(
                icon: Icons.library_books_outlined,
                message: '暂无方法数据',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MethodListBloc>().add(const RefreshMethods());
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 欢迎横幅
                  SliverToBoxAdapter(
                    child: _buildWelcomeBanner(),
                  ),

                  // 分类选择器
                  SliverToBoxAdapter(
                    child: _buildCategorySelector(),
                  ),

                  // 方法列表
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= methods.length) {
                            return state is MethodListLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: LoadingIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }
                          return _buildMethodCard(methods[index]);
                        },
                        childCount: methods.length + (state is MethodListLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 构建欢迎横幅
  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎回来！',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '让我们一起开始今天的练习',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector() {
    final categories = [
      {'id': null, 'name': '全部'},
      {'id': 'anxiety', 'name': '焦虑缓解'},
      {'id': 'sleep', 'name': '睡眠改善'},
      {'id': 'mood', 'name': '情绪管理'},
      {'id': 'stress', 'name': '压力释放'},
      {'id': 'mindfulness', 'name': '正念冥想'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category['name'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? (category['id'] as String?) : null;
                });
                context
                    .read<MethodListBloc>()
                    .add(FilterMethodsByCategory(_selectedCategory));
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建方法卡片
  Widget _buildMethodCard(Method method) {
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
            arguments: method.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 封面图占位
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: method.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              method.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  // 方法信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(Icons.layers, method.difficulty),
                            const SizedBox(width: 8),
                            if (method.durationMinutes != null)
                              _buildInfoChip(
                                  Icons.schedule, '${method.durationMinutes}分钟'),
                          ],
                        ),
                      ],
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

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
