import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/method_remote_data_source.dart';
import 'package:mental_app/data/repositories/method_repository_impl.dart';
import 'package:mental_app/presentation/methods/bloc/method_search_bloc.dart';
import 'package:mental_app/presentation/methods/bloc/method_search_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_search_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法搜索页面
class MethodSearchPage extends StatelessWidget {
  const MethodSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        const secureStorage = FlutterSecureStorage();
        final dioClient = DioClient(secureStorage);
        final remoteDataSource = MethodRemoteDataSource(dioClient);
        final repository = MethodRepositoryImpl(remoteDataSource: remoteDataSource);

        return MethodSearchBloc(methodRepository: repository)
          ..add(const LoadSearchHistory());
      },
      child: const _MethodSearchView(),
    );
  }
}

class _MethodSearchView extends StatefulWidget {
  const _MethodSearchView();

  @override
  State<_MethodSearchView> createState() => _MethodSearchViewState();
}

class _MethodSearchViewState extends State<_MethodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 延迟500ms后触发搜索
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<MethodSearchBloc>().add(
              SearchMethods(query: query, category: _selectedCategory),
            );
      } else {
        context.read<MethodSearchBloc>().add(const ClearSearch());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索方法...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<MethodSearchBloc>().add(const ClearSearch());
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Column(
        children: [
          // 分类筛选
          _buildCategoryFilter(),

          // 搜索结果/搜索历史
          Expanded(
            child: BlocBuilder<MethodSearchBloc, MethodSearchState>(
              builder: (context, state) {
                if (state is MethodSearchLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is MethodSearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }

                if (state is MethodSearchLoaded) {
                  if (state.results.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      message: '未找到相关方法\n换个关键词试试',
                      actionText: '清空搜索',
                      onAction: () {
                        _searchController.clear();
                        context.read<MethodSearchBloc>().add(const ClearSearch());
                      },
                    );
                  }

                  return _buildSearchResults(state.results, state.query);
                }

                if (state is MethodSearchInitial || state is SearchHistoryLoaded) {
                  final history = state is MethodSearchInitial
                      ? state.searchHistory
                      : (state as SearchHistoryLoaded).history;

                  return _buildSearchHistory(history);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分类筛选
  Widget _buildCategoryFilter() {
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
            child: FilterChip(
              label: Text(category['name'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category['id'] : null;
                });

                // 如果有搜索内容，重新搜索
                if (_searchController.text.trim().isNotEmpty) {
                  context.read<MethodSearchBloc>().add(
                        SearchMethods(
                          query: _searchController.text,
                          category: _selectedCategory,
                        ),
                      );
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

  /// 构建搜索历史
  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        message: '暂无搜索历史',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  context.read<MethodSearchBloc>().add(const ClearSearchHistory());
                },
                child: const Text('清空'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                onTap: () {
                  _searchController.text = query;
                  context.read<MethodSearchBloc>().add(
                        SearchMethods(query: query, category: _selectedCategory),
                      );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    _searchController.text = query;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(List<Method> results, String query) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '找到 ${results.length} 个结果',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildMethodCard(results[index], query);
            },
          ),
        ),
      ],
    );
  }

  /// 构建方法卡片（高亮关键词）
  Widget _buildMethodCard(Method method, String query) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
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
              // 方法名称（高亮显示）
              _buildHighlightedText(
                method.name,
                query,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // 方法描述（高亮显示）
              _buildHighlightedText(
                method.description,
                query,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // 分类标签
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getCategoryName(method.category),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      method.difficulty,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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

  /// 构建高亮文本
  Widget _buildHighlightedText(
    String text,
    String query, {
    TextStyle? style,
    int? maxLines,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      );
    }

    return RichText(
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(
              backgroundColor: Colors.yellow.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  /// 获取分类名称
  String _getCategoryName(String category) {
    const categoryMap = {
      'anxiety': '焦虑缓解',
      'sleep': '睡眠改善',
      'mood': '情绪管理',
      'stress': '压力释放',
      'mindfulness': '正念冥想',
    };
    return categoryMap[category] ?? category;
  }
}
