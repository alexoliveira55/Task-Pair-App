import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_validation_entity.dart';

class TaskValidationModel {
  final String id;
  final String executionId;
  final String occurrenceId;
  final String validatedBy;
  final DateTime validatedAt;
  final bool isApproved;
  final String? feedback;
  final String? pairId; // Denormalized for efficient Firestore queries

  const TaskValidationModel({
    required this.id,
    required this.executionId,
    required this.occurrenceId,
    required this.validatedBy,
    required this.validatedAt,
    required this.isApproved,
    this.feedback,
    this.pairId,
  });

  factory TaskValidationModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskValidationModel(
      id: id,
      executionId: map['executionId'] as String,
      occurrenceId: map['occurrenceId'] as String,
      validatedBy: map['validatedBy'] as String,
      validatedAt: (map['validatedAt'] as Timestamp).toDate(),
      isApproved: map['isApproved'] as bool,
      feedback: map['feedback'] as String?,
      pairId: map['pairId'] as String?,
    );
  }

  factory TaskValidationModel.fromEntity(TaskValidationEntity entity,
      {String? pairId}) {
    return TaskValidationModel(
      id: entity.id,
      executionId: entity.executionId,
      occurrenceId: entity.occurrenceId,
      validatedBy: entity.validatedBy,
      validatedAt: entity.validatedAt,
      isApproved: entity.isApproved,
      feedback: entity.feedback,
      pairId: pairId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'executionId': executionId,
      'occurrenceId': occurrenceId,
      'validatedBy': validatedBy,
      'validatedAt': Timestamp.fromDate(validatedAt),
      'isApproved': isApproved,
      'feedback': feedback,
      if (pairId != null) 'pairId': pairId,
    };
  }

  TaskValidationEntity toEntity() {
    return TaskValidationEntity(
      id: id,
      executionId: executionId,
      occurrenceId: occurrenceId,
      validatedBy: validatedBy,
      validatedAt: validatedAt,
      isApproved: isApproved,
      feedback: feedback,
    );
  }
}
