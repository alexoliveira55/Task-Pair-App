import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pair_entity.dart';

class PairModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final String name;
  final int scoreTarget;

  const PairModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.name,
    required this.scoreTarget,
  });

  factory PairModel.fromMap(Map<String, dynamic> map, String id) {
    return PairModel(
      id: id,
      user1Id: map['user1Id'] as String,
      user2Id: map['user2Id'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      name: map['name'] as String,
      scoreTarget: (map['scoreTarget'] as num).toInt(),
    );
  }

  factory PairModel.fromEntity(PairEntity entity) {
    return PairModel(
      id: entity.id,
      user1Id: entity.user1Id,
      user2Id: entity.user2Id,
      createdAt: entity.createdAt,
      name: entity.name,
      scoreTarget: entity.scoreTarget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': Timestamp.fromDate(createdAt),
      'name': name,
      'scoreTarget': scoreTarget,
    };
  }

  PairEntity toEntity() {
    return PairEntity(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      createdAt: createdAt,
      name: name,
      scoreTarget: scoreTarget,
    );
  }
}
