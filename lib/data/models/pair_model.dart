import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pair_entity.dart';

class PairModel {
  final String id;
  final String requesterId;
  final String executorId;
  final DateTime createdAt;
  final String name;
  final int scoreTarget;

  const PairModel({
    required this.id,
    required this.requesterId,
    required this.executorId,
    required this.createdAt,
    required this.name,
    required this.scoreTarget,
  });

  factory PairModel.fromMap(Map<String, dynamic> map, String id) {
    return PairModel(
      id: id,
      requesterId: map['requesterId'] as String,
      executorId: map['executorId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      name: map['name'] as String,
      scoreTarget: (map['scoreTarget'] as num).toInt(),
    );
  }

  factory PairModel.fromEntity(PairEntity entity) {
    return PairModel(
      id: entity.id,
      requesterId: entity.requesterId,
      executorId: entity.executorId,
      createdAt: entity.createdAt,
      name: entity.name,
      scoreTarget: entity.scoreTarget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'executorId': executorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'name': name,
      'scoreTarget': scoreTarget,
    };
  }

  PairEntity toEntity() {
    return PairEntity(
      id: id,
      requesterId: requesterId,
      executorId: executorId,
      createdAt: createdAt,
      name: name,
      scoreTarget: scoreTarget,
    );
  }
}
