import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pair_invite_entity.dart';

class PairInviteModel {
  final String id;
  final String fromUserId;
  final String toEmail;
  final String pairId;
  final String status;
  final DateTime createdAt;

  const PairInviteModel({
    required this.id,
    required this.fromUserId,
    required this.toEmail,
    required this.pairId,
    required this.status,
    required this.createdAt,
  });

  factory PairInviteModel.fromMap(Map<String, dynamic> map, String id) {
    return PairInviteModel(
      id: id,
      fromUserId: map['fromUserId'] as String,
      toEmail: map['toEmail'] as String,
      pairId: map['pairId'] as String,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory PairInviteModel.fromEntity(PairInviteEntity entity) {
    return PairInviteModel(
      id: entity.id,
      fromUserId: entity.fromUserId,
      toEmail: entity.toEmail,
      pairId: entity.pairId,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toEmail': toEmail,
      'pairId': pairId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PairInviteEntity toEntity() {
    return PairInviteEntity(
      id: id,
      fromUserId: fromUserId,
      toEmail: toEmail,
      pairId: pairId,
      status: status,
      createdAt: createdAt,
    );
  }
}
