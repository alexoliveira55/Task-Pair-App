import 'package:equatable/equatable.dart';

class TaskOccurrenceEntity extends Equatable {
  final String id;
  final String taskId;
  final String pairId;
  final DateTime dueDate;
  final String status; // pending, executed, validated, missed
  final String? assignedTo;

  const TaskOccurrenceEntity({
    required this.id,
    required this.taskId,
    required this.pairId,
    required this.dueDate,
    required this.status,
    this.assignedTo,
  });

  TaskOccurrenceEntity copyWith({
    String? id,
    String? taskId,
    String? pairId,
    DateTime? dueDate,
    String? status,
    String? assignedTo,
  }) {
    return TaskOccurrenceEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      pairId: pairId ?? this.pairId,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  List<Object?> get props =>
      [id, taskId, pairId, dueDate, status, assignedTo];
}
