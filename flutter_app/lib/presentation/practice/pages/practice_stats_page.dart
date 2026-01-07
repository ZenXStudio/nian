import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/practice_remote_data_source.dart';
import 'package:mental_app/data/repositories/practice_repository_impl.dart';
import 'package:mental_app/presentation/practice/bloc/practice_stats_bloc.dart';
import 'package:mental_app/presentation/practice/bloc/practice_stats_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_stats_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';
import 'package:mental_app/presentation/widgets/error_widget.dart' as app_error;

/// 练习统计页面
class PracticeStatsPage extends StatelessWidget {
  const PracticeStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        const secureStorage = FlutterSecureStorage();
        final dioClient = DioClient(secureStorage);
        final remoteDataSource = PracticeRemoteDataSource(dioClient);
        final repository =
            PracticeRepositoryImpl(remoteDataSource: remoteDataSource);

        return PracticeStatsBloc(practiceRepository: repository)
          ..add(const LoadPracticeStats(days: 30));
      },
      child: const _PracticeStatsView(),
    );
  }
}

class _PracticeStatsView extends StatefulWidget {
  const _PracticeStatsView();

  @override
  State<_PracticeStatsView> createState() => _PracticeStatsViewState();
}

class _PracticeStatsViewState extends State<_PracticeStatsView> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习统计'),
      ),
      body: Column(
        children: [
          // 时间范围选择
          _buildTimeRangeSelector(),

          // 统计内容
          Expanded(
            child: BlocBuilder<PracticeStatsBloc, PracticeStatsState>(
              builder: (context, state) {
                if (state is PracticeStatsLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is PracticeStatsError) {
                  return Center(
                    child: app_error.AppErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<PracticeStatsBloc>()
                            .add(LoadPracticeStats(days: _selectedDays));
                      },
                    ),
                  );
                }

                if (state is PracticeStatsLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 关键指标卡片
                        _buildKeyMetrics(state),

                        const SizedBox(height: 16),

                        // 练习改善度卡片
                        _buildImprovementCard(state),

                        const SizedBox(height: 16),

                        // 练习频次说明
                        _buildFrequencyNote(state),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    final ranges = [
      {'label': '近7天', 'days': 7},
      {'label': '近30天', 'days': 30},
      {'label': '近90天', 'days': 90},
      {'label': '全部', 'days': 365},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ranges.length,
        itemBuilder: (context, index) {
          final range = ranges[index];
          final days = range['days'] as int;
          final isSelected = _selectedDays == days;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(range['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDays = days;
                  });
                  context
                      .read<PracticeStatsBloc>()
                      .add(LoadPracticeStats(days: days));
                }
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

  /// 构建关键指标
  Widget _buildKeyMetrics(PracticeStatsLoaded state) {
    final totalMinutes = state.stats.totalCount * 15; // 简化计算
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '总练习次数',
            '${state.stats.totalCount}',
            '次',
            Icons.check_circle,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '总练习时长',
            hours > 0 ? '$hours' : '$minutes',
            hours > 0 ? '小时' : '分钟',
            Icons.schedule,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// 构建指标卡片
  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建改善度卡片
  Widget _buildImprovementCard(PracticeStatsLoaded state) {
    final improvement = state.stats.averageImprovement;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 32,
                  color: improvement > 0 ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '平均心情改善',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              improvement > 0 ? '+${improvement.toStringAsFixed(1)}' : '0',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: improvement > 0 ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              improvement > 0
                  ? '练习后心情平均提升${improvement.toStringAsFixed(1)}分'
                  : '暂无足够数据',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建频次说明
  Widget _buildFrequencyNote(PracticeStatsLoaded state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '练习建议',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• 建议每周练习3-5次，每次10-30分钟\n'
              '• 坚持练习可以获得更好的效果\n'
              '• 记录练习感受有助于追踪进步',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
