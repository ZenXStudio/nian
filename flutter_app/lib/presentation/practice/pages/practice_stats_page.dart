import 'package:flutter/material.dart';

/// 练习统计页面（占位）
class PracticeStatsPage extends StatefulWidget {
  const PracticeStatsPage({super.key});

  @override
  State<PracticeStatsPage> createState() => _PracticeStatsPageState();
}

class _PracticeStatsPageState extends State<PracticeStatsPage> {
  String _selectedTimeRange = '最近7天';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习统计'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 时间范围选择
          _buildTimeRangeSelector(),
          
          const SizedBox(height: 24),
          
          // 总体统计卡片
          _buildOverallStats(),
          
          const SizedBox(height: 24),
          
          // 练习频率图表占位
          _buildChartPlaceholder('练习频率', Icons.bar_chart),
          
          const SizedBox(height: 16),
          
          // 心理状态趋势图表占位
          _buildChartPlaceholder('心理状态趋势', Icons.show_chart),
          
          const SizedBox(height: 16),
          
          // 方法分布图表占位
          _buildChartPlaceholder('方法分布', Icons.pie_chart),
        ],
      ),
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    final timeRanges = ['最近7天', '最近30天', '最近90天'];
    
    return Row(
      children: timeRanges.map((range) {
        final isSelected = _selectedTimeRange == range;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(range),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                  // TODO: 加载对应时间范围的数据
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建总体统计
  Widget _buildOverallStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总体统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总练习次数', '28次', Icons.check_circle, Colors.blue),
                _buildStatItem('总时长', '240分钟', Icons.schedule, Colors.green),
                _buildStatItem('平均改善', '+2.5分', Icons.trending_up, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建图表占位符
  Widget _buildChartPlaceholder(String title, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '图表加载中...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// 练习统计页面（占位）
class PracticeStatsPage extends StatefulWidget {
  const PracticeStatsPage({super.key});

  @override
  State<PracticeStatsPage> createState() => _PracticeStatsPageState();
}

class _PracticeStatsPageState extends State<PracticeStatsPage> {
  String _selectedTimeRange = '最近7天';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习统计'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 时间范围选择
          _buildTimeRangeSelector(),
          
          const SizedBox(height: 24),
          
          // 总体统计卡片
          _buildOverallStats(),
          
          const SizedBox(height: 24),
          
          // 练习频率图表占位
          _buildChartPlaceholder('练习频率', Icons.bar_chart),
          
          const SizedBox(height: 16),
          
          // 心理状态趋势图表占位
          _buildChartPlaceholder('心理状态趋势', Icons.show_chart),
          
          const SizedBox(height: 16),
          
          // 方法分布图表占位
          _buildChartPlaceholder('方法分布', Icons.pie_chart),
        ],
      ),
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    final timeRanges = ['最近7天', '最近30天', '最近90天'];
    
    return Row(
      children: timeRanges.map((range) {
        final isSelected = _selectedTimeRange == range;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(range),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                  // TODO: 加载对应时间范围的数据
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建总体统计
  Widget _buildOverallStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总体统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总练习次数', '28次', Icons.check_circle, Colors.blue),
                _buildStatItem('总时长', '240分钟', Icons.schedule, Colors.green),
                _buildStatItem('平均改善', '+2.5分', Icons.trending_up, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建图表占位符
  Widget _buildChartPlaceholder(String title, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '图表加载中...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
