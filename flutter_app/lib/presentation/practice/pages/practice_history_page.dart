import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/practice_remote_data_source.dart';
import 'package:mental_app/data/repositories/practice_repository_impl.dart';
import 'package:mental_app/presentation/practice/bloc/practice_history_bloc.dart';
import 'package:mental_app/presentation/practice/bloc/practice_history_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_history_state.dart';
import 'package:mental_app/presentation/widgets/empty_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';
import 'package:mental_app/presentation/widgets/error_widget.dart' as app_error;
import 'package:mental_app/core/utils/date_formatter.dart';

/// 练习历史列表页
class PracticeHistoryPage extends StatelessWidget {
  const PracticeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        const secureStorage = FlutterSecureStorage();
        final dioClient = DioClient(secureStorage);
        final remoteDataSource = PracticeRemoteDataSource(dioClient);
        final repository =
            PracticeRepositoryImpl(remoteDataSource: remoteDataSource);

        return PracticeHistoryBloc(practiceRepository: repository)
          ..add(const LoadPracticeHistory(timeRange: 'week'));
      },
      child: const _PracticeHistoryView(),
    );
  }
}

class _PracticeHistoryView extends StatefulWidget {
  const _PracticeHistoryView();

  @override
  State<_PracticeHistoryView> createState() => _PracticeHistoryViewState();
}

class _PracticeHistoryViewState extends State<_PracticeHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      String timeRange;
      switch (_tabController.index) {
        case 0:
          timeRange = 'week'; // 本周
          break;
        case 1:
          timeRange = 'month'; // 本月
          break;
        case 2:
          timeRange = 'all'; // 全部
          break;
        default:
          timeRange = 'week';
      }
      context
          .read<PracticeHistoryBloc>()
          .add(LoadPracticeHistory(timeRange: timeRange));
    }
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
    return BlocBuilder<PracticeHistoryBloc, PracticeHistoryState>(
      builder: (context, state) {
        int totalCount = 0;
        int weekCount = 0;
        int consecutiveDays = 0;

        if (state is PracticeHistoryLoaded) {
          totalCount = state.records.length;
          // 简化统计，实际应从 state获取
          weekCount = state.records
              .where((r) =>
                  DateTime.now().difference(r.createdAt).inDays < 7)
              .length;
          consecutiveDays = _calculateConsecutiveDays(state.records);
        }

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
              _buildStatItem('总练习', '$totalCount次'),
              _buildDivider(),
              _buildStatItem('本周', '$weekCount次'),
              _buildDivider(),
              _buildStatItem('连续', '$consecutiveDays天'),
            ],
          ),
        );
      },
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
    return BlocBuilder<PracticeHistoryBloc, PracticeHistoryState>(
      builder: (context, state) {
        if (state is PracticeHistoryLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is PracticeHistoryError) {
          return Center(
            child: app_error.AppErrorWidget(
              message: state.message,
              onRetry: () {
                context
                    .read<PracticeHistoryBloc>()
                    .add(const LoadPracticeHistory(timeRange: 'week'));
              },
            ),
          );
        }

        if (state is PracticeHistoryLoaded) {
          if (state.records.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: '还没有练习记录\n开始第一次练习吧',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              String timeRange = 'week';
              switch (_tabController.index) {
                case 0:
                  timeRange = 'week';
                  break;
                case 1:
                  timeRange = 'month';
                  break;
                case 2:
                  timeRange = 'all';
                  break;
              }
              context
                  .read<PracticeHistoryBloc>()
                  .add(LoadPracticeHistory(timeRange: timeRange));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                final showDateHeader = index == 0 ||
                    !_isSameDay(state.records[index - 1].createdAt,
                        record.createdAt);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          DateFormatter.getRelativeTime(record.createdAt),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    _buildPracticeCard(record),
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 计算连续练习天数
  int _calculateConsecutiveDays(List<dynamic> records) {
    if (records.isEmpty) return 0;
    
    // 获取所有练习日期（去重）
    final dates = records
        .map((r) => DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a)); // 按日期降序
    
    // 检查从今天开始的连续天数
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int consecutiveDays = 0;
    DateTime checkDate = todayDate;
    
    for (final date in dates) {
      if (date.isAtSameMomentAs(checkDate) ||
          checkDate.difference(date).inDays == 0) {
        consecutiveDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (checkDate.difference(date).inDays == 1) {
        // 今天没有练习但昨天有
        consecutiveDays++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 构建练习卡片
  Widget _buildPracticeCard(dynamic record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // 查看练习详情
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
                      record.methodName ?? '练习记录',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    DateFormatter.formatTime(record.createdAt),
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
                    '练习时长: ${record.durationMinutes}分钟',
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
                    child: _buildMoodIndicator(
                        '练习前', record.moodBefore, Colors.orange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMoodIndicator(
                        '练习后', record.moodAfter, Colors.green),
                  ),
                ],
              ),

              // 备注（如果有）
              if (record.notes != null && record.notes!.isNotEmpty) ...[
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
                          record.notes!,
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
}
