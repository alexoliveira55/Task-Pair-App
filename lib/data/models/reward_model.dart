import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reward_entity.dart';

class RewardModel {
  final String id;
  final String pairId;
  final String title;
  final String? description;
  final int requiredPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const RewardModel({
    required this.id,
    required this.pairId,
    required this.title,
    this.description,
    required this.requiredPoints,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory RewardModel.fromMap(Map<String, dynamic> map, String id) {
    return RewardModel(
      id: id,
      pairId: map['pairId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      requiredPoints: (map['requiredPoints'] as num).toInt(),
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      unlockedAt: (map['unlockedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory RewardModel.fromEntity(RewardEntity entity) {
    return RewardModel(
      id: entity.id,
      pairId: entity.pairId,
      title: entity.title,
      description: entity.description,
      requiredPoints: entity.requiredPoints,
      isUnlocked: entity.isUnlocked,
      unlockedAt: entity.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pairId': pairId,
      'title': title,
      'description': description,
      'requiredPoints': requiredPoints,
      'isUnlocked': isUnlocked,
      'unlockedAt':
          unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  RewardEntity toEntity() {
    return RewardEntity(
      id: id,
      pairId: pairId,
      title: title,
      description: description,
      requiredPoints: requiredPoints,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }
}
