import 'package:equatable/equatable.dart';

class TaskOccurrenceEntity extends Equatable {
  final String id;
  final String taskId;
  final String pairId;
  final DateTime dueDate;
  final String? scheduledStartTime;
  final int? expectedDuration;
  final String
      status; // pending, in_progress, executed, validated, missed, expired
  final String? assignedTo;
  final String? executionId;

  const TaskOccurrenceEntity({
    required this.id,
    required this.taskId,
    required this.pairId,
    required this.dueDate,
    this.scheduledStartTime,
    this.expectedDuration,
    required this.status,
    this.assignedTo,
    this.executionId,
  });

  TaskOccurrenceEntity copyWith({
    String? id,
    String? taskId,
    String? pairId,
    DateTime? dueDate,
    String? scheduledStartTime,
    int? expectedDuration,
    String? status,
    String? assignedTo,
    String? executionId,
  }) {
    return TaskOccurrenceEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      pairId: pairId ?? this.pairId,
      dueDate: dueDate ?? this.dueDate,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      executionId: executionId ?? this.executionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        pairId,
        dueDate,
        scheduledStartTime,
        expectedDuration,
        status,
        assignedTo,
        executionId
      ];
}
