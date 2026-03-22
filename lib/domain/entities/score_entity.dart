import 'package:equatable/equatable.dart';

class ScoreEntity extends Equatable {
  final String id;
  final String pairId;
  final String userId;
  final int totalPoints;
  final int periodPoints;
  final DateTime updatedAt;

  const ScoreEntity({
    required this.id,
    required this.pairId,
    required this.userId,
    required this.totalPoints,
    required this.periodPoints,
    required this.updatedAt,
  });

  ScoreEntity copyWith({
    String? id,
    String? pairId,
    String? userId,
    int? totalPoints,
    int? periodPoints,
    DateTime? updatedAt,
  }) {
    return ScoreEntity(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      periodPoints: periodPoints ?? this.periodPoints,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, pairId, userId, totalPoints, periodPoints, updatedAt];
}
