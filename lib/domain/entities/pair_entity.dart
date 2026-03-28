import 'package:equatable/equatable.dart';

class PairEntity extends Equatable {
  final String id;
  final String requesterId;
  final String executorId;
  final DateTime createdAt;
  final String name;
  final int scoreTarget;

  const PairEntity({
    required this.id,
    required this.requesterId,
    required this.executorId,
    required this.createdAt,
    required this.name,
    required this.scoreTarget,
  });

  PairEntity copyWith({
    String? id,
    String? requesterId,
    String? executorId,
    DateTime? createdAt,
    String? name,
    int? scoreTarget,
  }) {
    return PairEntity(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      executorId: executorId ?? this.executorId,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      scoreTarget: scoreTarget ?? this.scoreTarget,
    );
  }

  @override
  List<Object?> get props =>
      [id, requesterId, executorId, createdAt, name, scoreTarget];
}
