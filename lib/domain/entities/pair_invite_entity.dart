import 'package:equatable/equatable.dart';

class PairInviteEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String toEmail;
  final String pairId;
  final String status;
  final DateTime createdAt;
  final String pairName;
  final int scoreTarget;

  const PairInviteEntity({
    required this.id,
    required this.fromUserId,
    required this.toEmail,
    required this.pairId,
    required this.status,
    required this.createdAt,
    this.pairName = '',
    this.scoreTarget = 100,
  });

  PairInviteEntity copyWith({
    String? id,
    String? fromUserId,
    String? toEmail,
    String? pairId,
    String? status,
    DateTime? createdAt,
    String? pairName,
    int? scoreTarget,
  }) {
    return PairInviteEntity(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toEmail: toEmail ?? this.toEmail,
      pairId: pairId ?? this.pairId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pairName: pairName ?? this.pairName,
      scoreTarget: scoreTarget ?? this.scoreTarget,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toEmail,
        pairId,
        status,
        createdAt,
        pairName,
        scoreTarget
      ];
}
