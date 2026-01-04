import 'package:flutter/material.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';

/// 练习历史列表页
class PracticeHistoryPage extends StatefulWidget {
  const PracticeHistoryPage({super.key});

  @override
  State<PracticeHistoryPage> createState() => _PracticeHistoryPageState();
}

class _PracticeHistoryPageState extends State<PracticeHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '本周'),
            Tab(text: '本月'),
            Tab(text: '全部'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 顶部统计卡片
          _buildStatisticsCard(),
          
          // 练习记录列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPracticeList(),
                _buildPracticeList(),
                _buildPracticeList(),
              ],
            ),
          ),
        ],
      ),
      // 查看统计按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/practice-stats');
        },
        child: const Icon(Icons.bar_chart),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总练习', '28次'),
          _buildDivider(),
          _buildStatItem('本周', '5次'),
          _buildDivider(),
          _buildStatItem('连续', '7天'),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  /// 构建练习列表
  Widget _buildPracticeList() {
    // TODO: 集成 BLoC 加载真实数据
    
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10, // 临时显示10条记录
        itemBuilder: (context, index) {
          // 每3条记录显示一个日期分组
          if (index % 3 == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(index),
                _buildPracticeCard(index),
              ],
            );
          }
          return _buildPracticeCard(index);
        },
      ),
    );
  }

  /// 构建日期分组头
  Widget _buildDateHeader(int index) {
    final dates = ['今天', '昨天', '2天前', '3天前'];
    final dateIndex = index ~/ 3;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        dates[dateIndex % dates.length],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// 构建练习卡片
  Widget _buildPracticeCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 查看练习详情
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 方法名称和时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '深呼吸练习',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '14:30',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 练习时长
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '练习时长: 10分钟',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 心理状态评分
              Row(
                children: [
                  Expanded(
                    child: _buildMoodIndicator('练习前', 4, Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMoodIndicator('练习后', 8, Colors.green),
                  ),
                ],
              ),
              
              // 备注（如果有）
              if (index % 4 == 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '今天感觉好多了，会继续坚持练习',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建心情指示器
  Widget _buildMoodIndicator(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
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
