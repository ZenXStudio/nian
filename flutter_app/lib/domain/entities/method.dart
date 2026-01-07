import 'package:equatable/equatable.dart';

/// 心理方法实体
///
/// 表示系统中的心理自助方法
class Method extends Equatable {
  /// 方法ID
  final int id;
  
  /// 方法名称
  final String name;
  
  /// 描述
  final String description;
  
  /// 分类
  final String category;
  
  /// 难度
  final String difficulty;
  
  /// 建议时长（分钟）
  final int? durationMinutes;
  
  /// 封面图片URL
  final String? imageUrl;
  
  /// 音频URL
  final String? audioUrl;
  
  /// 视频URL
  final String? videoUrl;
  
  /// 方法内容（JSON格式）
  final Map<String, dynamic>? contentJson;
  
  /// 封面图片URL（别名）
  String? get coverImageUrl => imageUrl;
  
  /// 详细内容
  String? get detailedContent => contentJson?['detailedContent'] as String?;
  
  /// 步骤列表
  List<String> get steps => (contentJson?['steps'] as List<dynamic>?)?.cast<String>() ?? [];
  
  /// 注意事项
  List<String> get precautions => (contentJson?['precautions'] as List<dynamic>?)?.cast<String>() ?? [];
  
  /// 浏览次数
  final int viewCount;
  
  /// 创建时间
  final DateTime createdAt;

  const Method({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    this.durationMinutes,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.contentJson,
    required this.viewCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        difficulty,
        durationMinutes,
        imageUrl,
        audioUrl,
        videoUrl,
        contentJson,
        viewCount,
        createdAt,
      ];

  @override
  String toString() => 'Method(id: $id, name: $name, category: $category)';
}
