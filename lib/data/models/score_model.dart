import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/score_entity.dart';

class ScoreModel {
  final String id;
  final String pairId;
  final String userId;
  final int totalPoints;
  final int periodPoints;
  final DateTime updatedAt;

  const ScoreModel({
    required this.id,
    required this.pairId,
    required this.userId,
    required this.totalPoints,
    required this.periodPoints,
    required this.updatedAt,
  });

  factory ScoreModel.fromMap(Map<String, dynamic> map, String id) {
    return ScoreModel(
      id: id,
      pairId: map['pairId'] as String,
      userId: map['userId'] as String,
      totalPoints: (map['totalPoints'] as num).toInt(),
      periodPoints: (map['periodPoints'] as num).toInt(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ScoreModel.fromEntity(ScoreEntity entity) {
    return ScoreModel(
      id: entity.id,
      pairId: entity.pairId,
      userId: entity.userId,
      totalPoints: entity.totalPoints,
      periodPoints: entity.periodPoints,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pairId': pairId,
      'userId': userId,
      'totalPoints': totalPoints,
      'periodPoints': periodPoints,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ScoreEntity toEntity() {
    return ScoreEntity(
      id: id,
      pairId: pairId,
      userId: userId,
      totalPoints: totalPoints,
      periodPoints: periodPoints,
      updatedAt: updatedAt,
    );
  }
}
