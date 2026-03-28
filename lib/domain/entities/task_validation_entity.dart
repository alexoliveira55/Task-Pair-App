import 'package:equatable/equatable.dart';

class TaskValidationEntity extends Equatable {
  final String id;
  final String executionId;
  final String occurrenceId;
  final String validatedBy;
  final DateTime validatedAt;
  final int percentage; // 0-100 (0 = não cumprida)
  final String? feedback;

  const TaskValidationEntity({
    required this.id,
    required this.executionId,
    required this.occurrenceId,
    required this.validatedBy,
    required this.validatedAt,
    required this.percentage,
    this.feedback,
  });

  TaskValidationEntity copyWith({
    String? id,
    String? executionId,
    String? occurrenceId,
    String? validatedBy,
    DateTime? validatedAt,
    int? percentage,
    String? feedback,
  }) {
    return TaskValidationEntity(
      id: id ?? this.id,
      executionId: executionId ?? this.executionId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      validatedBy: validatedBy ?? this.validatedBy,
      validatedAt: validatedAt ?? this.validatedAt,
      percentage: percentage ?? this.percentage,
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
        percentage,
        feedback,
      ];
}
