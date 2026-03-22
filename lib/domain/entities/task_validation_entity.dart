import 'package:equatable/equatable.dart';

class TaskValidationEntity extends Equatable {
  final String id;
  final String executionId;
  final String occurrenceId;
  final String validatedBy;
  final DateTime validatedAt;
  final bool isApproved;
  final String? feedback;

  const TaskValidationEntity({
    required this.id,
    required this.executionId,
    required this.occurrenceId,
    required this.validatedBy,
    required this.validatedAt,
    required this.isApproved,
    this.feedback,
  });

  TaskValidationEntity copyWith({
    String? id,
    String? executionId,
    String? occurrenceId,
    String? validatedBy,
    DateTime? validatedAt,
    bool? isApproved,
    String? feedback,
  }) {
    return TaskValidationEntity(
      id: id ?? this.id,
      executionId: executionId ?? this.executionId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      validatedBy: validatedBy ?? this.validatedBy,
      validatedAt: validatedAt ?? this.validatedAt,
      isApproved: isApproved ?? this.isApproved,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        executionId,
        occurrenceId,
        validatedBy,
        validatedAt,
        isApproved,
        feedback,
      ];
}
