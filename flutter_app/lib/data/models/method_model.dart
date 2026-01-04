import 'package:mental_app/domain/entities/method.dart';

/// 方法数据模型
class MethodModel extends Method {
  const MethodModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.difficulty,
    super.durationMinutes,
    super.imageUrl,
    super.audioUrl,
    super.videoUrl,
    super.contentJson,
    required super.viewCount,
    required super.createdAt,
  });

  factory MethodModel.fromJson(Map<String, dynamic> json) {
    return MethodModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      durationMinutes: json['durationMinutes'] as int?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      contentJson: json['contentJson'] as Map<String, dynamic>?,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'contentJson': contentJson,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
