import 'package:equatable/equatable.dart';

class TaskExecutionEntity extends Equatable {
  final String id;
  final String occurrenceId;
  final String taskId;
  final String executedBy;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final String? photoUrl;

  const TaskExecutionEntity({
    required this.id,
    required this.occurrenceId,
    required this.taskId,
    required this.executedBy,
    required this.startedAt,
    this.finishedAt,
    this.notes,
    this.photoUrl,
  });

  TaskExecutionEntity copyWith({
    String? id,
    String? occurrenceId,
    String? taskId,
    String? executedBy,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? notes,
    String? photoUrl,
  }) {
    return TaskExecutionEntity(
      id: id ?? this.id,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      taskId: taskId ?? this.taskId,
      executedBy: executedBy ?? this.executedBy,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        occurrenceId,
        taskId,
        executedBy,
        startedAt,
        finishedAt,
        notes,
        photoUrl
      ];
}
