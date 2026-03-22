import 'package:equatable/equatable.dart';

class TaskExecutionEntity extends Equatable {
  final String id;
  final String occurrenceId;
  final String taskId;
  final String executedBy;
  final DateTime executedAt;
  final String? notes;
  final String? photoUrl;

  const TaskExecutionEntity({
    required this.id,
    required this.occurrenceId,
    required this.taskId,
    required this.executedBy,
    required this.executedAt,
    this.notes,
    this.photoUrl,
  });

  TaskExecutionEntity copyWith({
    String? id,
    String? occurrenceId,
    String? taskId,
    String? executedBy,
    DateTime? executedAt,
    String? notes,
    String? photoUrl,
  }) {
    return TaskExecutionEntity(
      id: id ?? this.id,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      taskId: taskId ?? this.taskId,
      executedBy: executedBy ?? this.executedBy,
      executedAt: executedAt ?? this.executedAt,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props =>
      [id, occurrenceId, taskId, executedBy, executedAt, notes, photoUrl];
}
