import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String id;
  final String pairId;
  final String title;
  final String? description;
  final int requiredPoints;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const RewardEntity({
    required this.id,
    required this.pairId,
    required this.title,
    this.description,
    required this.requiredPoints,
    required this.isUnlocked,
    this.unlockedAt,
  });

  RewardEntity copyWith({
    String? id,
    String? pairId,
    String? title,
    String? description,
    int? requiredPoints,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return RewardEntity(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pairId,
        title,
        description,
        requiredPoints,
        isUnlocked,
        unlockedAt,
      ];
}
