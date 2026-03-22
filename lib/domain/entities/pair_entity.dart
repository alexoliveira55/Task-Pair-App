import 'package:equatable/equatable.dart';

class PairEntity extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final String name;
  final int scoreTarget;

  const PairEntity({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.name,
    required this.scoreTarget,
  });

  PairEntity copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
    String? name,
    int? scoreTarget,
  }) {
    return PairEntity(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      scoreTarget: scoreTarget ?? this.scoreTarget,
    );
  }

  @override
  List<Object?> get props =>
      [id, user1Id, user2Id, createdAt, name, scoreTarget];
}
