import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_execution_entity.dart';

class TaskExecutionModel {
  final String id;
  final String occurrenceId;
  final String taskId;
  final String executedBy;
  final DateTime executedAt;
  final String? notes;
  final String? photoUrl;

  const TaskExecutionModel({
    required this.id,
    required this.occurrenceId,
    required this.taskId,
    required this.executedBy,
    required this.executedAt,
    this.notes,
    this.photoUrl,
  });

  factory TaskExecutionModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskExecutionModel(
      id: id,
      occurrenceId: map['occurrenceId'] as String,
      taskId: map['taskId'] as String,
      executedBy: map['executedBy'] as String,
      executedAt: (map['executedAt'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  factory TaskExecutionModel.fromEntity(TaskExecutionEntity entity) {
    return TaskExecutionModel(
      id: entity.id,
      occurrenceId: entity.occurrenceId,
      taskId: entity.taskId,
      executedBy: entity.executedBy,
      executedAt: entity.executedAt,
      notes: entity.notes,
      photoUrl: entity.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'occurrenceId': occurrenceId,
      'taskId': taskId,
      'executedBy': executedBy,
      'executedAt': Timestamp.fromDate(executedAt),
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }

  TaskExecutionEntity toEntity() {
    return TaskExecutionEntity(
      id: id,
      occurrenceId: occurrenceId,
      taskId: taskId,
      executedBy: executedBy,
      executedAt: executedAt,
      notes: notes,
      photoUrl: photoUrl,
    );
  }
}
