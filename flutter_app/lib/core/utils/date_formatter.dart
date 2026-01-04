import 'package:intl/intl.dart';

/// 日期格式化工具类
/// 提供各种日期格式化和相对时间显示功能
class DateFormatter {
  /// 默认日期格式 yyyy-MM-dd
  static const String defaultDateFormat = 'yyyy-MM-dd';
  
  /// 默认时间格式 HH:mm:ss
  static const String defaultTimeFormat = 'HH:mm:ss';
  
  /// 默认日期时间格式 yyyy-MM-dd HH:mm:ss
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  /// 中文日期格式 yyyy年MM月dd日
  static const String chineseDateFormat = 'yyyy年MM月dd日';
  
  /// 中文日期时间格式 yyyy年MM月dd日 HH:mm
  static const String chineseDateTimeFormat = 'yyyy年MM月dd日 HH:mm';
  
  /// 格式化日期为字符串
  /// 
  /// [date] 要格式化的日期
  /// [format] 格式化模板，默认为 yyyy-MM-dd
  /// 
  /// 示例:
  /// ```dart
  /// formatDate(DateTime.now()) // "2026-01-04"
  /// formatDate(DateTime.now(), format: 'yyyy年MM月dd日') // "2026年01月04日"
  /// ```
  static String formatDate(DateTime date, {String format = defaultDateFormat}) {
    try {
      return DateFormat(format).format(date);
    } catch (e) {
      return date.toString();
    }
  }
  
  /// 格式化时间为字符串
  /// 
  /// [time] 要格式化的时间
  /// [format] 格式化模板，默认为 HH:mm:ss
  static String formatTime(DateTime time, {String format = defaultTimeFormat}) {
    try {
      return DateFormat(format).format(time);
    } catch (e) {
      return time.toString();
    }
  }
  
  /// 格式化日期时间为字符串
  /// 
  /// [dateTime] 要格式化的日期时间
  /// [format] 格式化模板，默认为 yyyy-MM-dd HH:mm:ss
  static String formatDateTime(
    DateTime dateTime,
    {String format = defaultDateTimeFormat},
  ) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }
  
  /// 获取相对时间描述
  /// 
  /// 根据时间差返回友好的相对时间描述，如：
  /// - 刚刚 (0-30秒)
  /// - N分钟前 (1-59分钟)
  /// - N小时前 (1-23小时)
  /// - 昨天 (昨天同一时间)
  /// - N天前 (2-6天)
  /// - yyyy-MM-dd (7天以上)
  /// 
  /// [dateTime] 要计算的时间
  /// [baseTime] 基准时间，默认为当前时间
  static String getRelativeTime(DateTime dateTime, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    final difference = base.difference(dateTime);
    
    // 未来时间
    if (difference.isNegative) {
      return formatDate(dateTime);
    }
    
    // 刚刚 (30秒内)
    if (difference.inSeconds < 30) {
      return '刚刚';
    }
    
    // N秒前 (30-59秒)
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    }
    
    // N分钟前 (1-59分钟)
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    }
    
    // N小时前 (1-23小时)
    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }
    
    // 昨天 (24-48小时内，且确实是昨天)
    if (difference.inDays == 1 && isYesterday(dateTime, baseTime: base)) {
      return '昨天 ${formatTime(dateTime, format: 'HH:mm')}';
    }
    
    // N天前 (2-6天)
    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }
    
    // 一周以上显示日期
    return formatDate(dateTime);
  }
  
  /// 获取详细的相对时间描述（包含具体时间）
  /// 
  /// 如：
  /// - 刚刚
  /// - 5分钟前
  /// - 昨天 18:30
  /// - 01-03 14:20
  /// - 2025-12-25 10:00
  static String getDetailedRelativeTime(DateTime dateTime, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    final difference = base.difference(dateTime);
    
    // 未来时间
    if (difference.isNegative) {
      return formatDateTime(dateTime, format: 'yyyy-MM-dd HH:mm');
    }
    
    // 1小时内显示相对时间
    if (difference.inMinutes < 60) {
      return getRelativeTime(dateTime, baseTime: base);
    }
    
    // 今天
    if (isToday(dateTime, baseTime: base)) {
      return '今天 ${formatTime(dateTime, format: 'HH:mm')}';
    }
    
    // 昨天
    if (isYesterday(dateTime, baseTime: base)) {
      return '昨天 ${formatTime(dateTime, format: 'HH:mm')}';
    }
    
    // 今年内
    if (dateTime.year == base.year) {
      return formatDateTime(dateTime, format: 'MM-dd HH:mm');
    }
    
    // 往年
    return formatDateTime(dateTime, format: 'yyyy-MM-dd HH:mm');
  }
  
  /// 判断是否是今天
  static bool isToday(DateTime date, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    return date.year == base.year &&
        date.month == base.month &&
        date.day == base.day;
  }
  
  /// 判断是否是昨天
  static bool isYesterday(DateTime date, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    final yesterday = base.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
  
  /// 判断是否是本周
  static bool isThisWeek(DateTime date, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    final weekStart = base.subtract(Duration(days: base.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd);
  }
  
  /// 判断是否是本月
  static bool isThisMonth(DateTime date, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    return date.year == base.year && date.month == base.month;
  }
  
  /// 判断是否是今年
  static bool isThisYear(DateTime date, {DateTime? baseTime}) {
    final base = baseTime ?? DateTime.now();
    return date.year == base.year;
  }
  
  /// 解析字符串为DateTime
  /// 
  /// 支持多种常见格式自动识别
  static DateTime? parseDate(String dateString) {
    if (dateString.isEmpty) return null;
    
    try {
      // 尝试ISO 8601格式
      return DateTime.parse(dateString);
    } catch (_) {
      // 尝试其他常见格式
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd',
        'yyyy/MM/dd HH:mm:ss',
        'yyyy/MM/dd HH:mm',
        'yyyy/MM/dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
      ];
      
      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (_) {
          continue;
        }
      }
      
      return null;
    }
  }
  
  /// 获取两个日期之间的天数差
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
  
  /// 获取月份的第一天
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 获取月份的最后一天
  static DateTime getLastDayOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }
  
  /// 获取星期几的中文名称
  static String getWeekdayName(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    if (weekday < 1 || weekday > 7) return '';
    return '星期${weekdays[weekday - 1]}';
  }
  
  /// 格式化时间段
  /// 
  /// 将秒数格式化为易读的时间段描述
  /// 如: 65秒 -> "1分钟5秒"
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds秒';
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      if (remainingSeconds == 0) {
        return '$minutes分钟';
      }
      return '$minutes分钟$remainingSeconds秒';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours < 24) {
      if (remainingMinutes == 0) {
        return '$hours小时';
      }
      return '$hours小时$remainingMinutes分钟';
    }
    
    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    
    if (remainingHours == 0) {
      return '$days天';
    }
    return '$days天$remainingHours小时';
  }
}
