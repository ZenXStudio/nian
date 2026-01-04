import 'package:flutter/material.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';

/// 个人方法库列表页
class UserMethodListPage extends StatefulWidget {
  const UserMethodListPage({super.key});

  @override
  State<UserMethodListPage> createState() => _UserMethodListPageState();
}

class _UserMethodListPageState extends State<UserMethodListPage> {
  String _selectedFilter = '全部';

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
            child: _buildMethodList(),
          ),
        ],
      ),
      // 添加按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 跳转到方法浏览页面
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
                  // TODO: 触发筛选事件
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

  /// 构建方法列表
  Widget _buildMethodList() {
    // TODO: 集成 BLoC 加载真实数据
    // 当前显示占位内容
    
    // 模拟空状态
    // return const EmptyState(
    //   icon: Icons.library_books_outlined,
    //   message: '还没有添加方法\n去首页浏览并添加感兴趣的方法吧',
    // );

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // 临时显示5个占位卡片
        itemBuilder: (context, index) {
          return _buildUserMethodCard(index);
        },
      ),
    );
  }

  /// 构建个人方法卡片
  Widget _buildUserMethodCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 跳转到个人方法详情页
          // Navigator.pushNamed(context, '/user-method-detail/$id');
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
                      '方法名称 ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      index % 2 == 0 ? Icons.favorite : Icons.favorite_border,
                      color: index % 2 == 0 ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      // TODO: 切换收藏状态
                    },
                  ),
                ],
              ),
              
              // 个人目标
              if (index % 3 != 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '我的目标：缓解焦虑，改善睡眠质量',
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
                  _buildStatItem(Icons.check_circle_outline, '练习', '${(index + 1) * 5}次'),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.schedule, '上次练习', '2天前'),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: 编辑目标
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('编辑目标'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 开始练习
                        Navigator.pushNamed(context, '/practice-create');
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

  /// 下拉刷新
  Future<void> _onRefresh() async {
    // TODO: 刷新数据
    await Future.delayed(const Duration(seconds: 1));
  }
}
