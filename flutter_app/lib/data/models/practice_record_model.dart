import 'package:mental_app/domain/entities/practice_record.dart';
import 'package:mental_app/data/models/method_model.dart';

/// 练习记录数据模型
class PracticeRecordModel extends PracticeRecord {
  const PracticeRecordModel({
    required super.id,
    required super.userId,
    required super.methodId,
    super.method,
    required super.durationMinutes,
    required super.moodBefore,
    required super.moodAfter,
    super.notes,
    required super.practicedAt,
  });

  factory PracticeRecordModel.fromJson(Map<String, dynamic> json) {
    return PracticeRecordModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      methodId: json['methodId'] as int,
      method: json['method'] != null
          ? MethodModel.fromJson(json['method'] as Map<String, dynamic>)
          : null,
      durationMinutes: json['durationMinutes'] as int,
      moodBefore: json['moodBefore'] as int,
      moodAfter: json['moodAfter'] as int,
      notes: json['notes'] as String?,
      practicedAt: DateTime.parse(json['practicedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'methodId': methodId,
      'durationMinutes': durationMinutes,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'notes': notes,
      'practicedAt': practicedAt.toIso8601String(),
    };
  }
}

/// 练习记录数据模型
class PracticeRecordModel extends PracticeRecord {
  const PracticeRecordModel({
    required super.id,
    required super.userId,
    required super.methodId,
    super.method,
    required super.durationMinutes,
    required super.moodBefore,
    required super.moodAfter,
    super.notes,
    required super.practicedAt,
  });

  factory PracticeRecordModel.fromJson(Map<String, dynamic> json) {
    return PracticeRecordModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      methodId: json['methodId'] as int,
      method: json['method'] != null
          ? MethodModel.fromJson(json['method'] as Map<String, dynamic>)
          : null,
      durationMinutes: json['durationMinutes'] as int,
      moodBefore: json['moodBefore'] as int,
      moodAfter: json['moodAfter'] as int,
      notes: json['notes'] as String?,
      practicedAt: DateTime.parse(json['practicedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'methodId': methodId,
      'durationMinutes': durationMinutes,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'notes': notes,
      'practicedAt': practicedAt.toIso8601String(),
    };
  }
}
