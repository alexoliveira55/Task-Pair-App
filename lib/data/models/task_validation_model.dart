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

  const TaskValidationModel({
    required this.id,
    required this.executionId,
    required this.occurrenceId,
    required this.validatedBy,
    required this.validatedAt,
    required this.isApproved,
    this.feedback,
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
    );
  }

  factory TaskValidationModel.fromEntity(TaskValidationEntity entity) {
    return TaskValidationModel(
      id: entity.id,
      executionId: entity.executionId,
      occurrenceId: entity.occurrenceId,
      validatedBy: entity.validatedBy,
      validatedAt: entity.validatedAt,
      isApproved: entity.isApproved,
      feedback: entity.feedback,
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
