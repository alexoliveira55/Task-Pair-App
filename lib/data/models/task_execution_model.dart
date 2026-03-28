import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_execution_entity.dart';

class TaskExecutionModel {
  final String id;
  final String occurrenceId;
  final String taskId;
  final String executedBy;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final String? photoUrl;

  const TaskExecutionModel({
    required this.id,
    required this.occurrenceId,
    required this.taskId,
    required this.executedBy,
    required this.startedAt,
    this.finishedAt,
    this.notes,
    this.photoUrl,
  });

  factory TaskExecutionModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskExecutionModel(
      id: id,
      occurrenceId: map['occurrenceId'] as String,
      taskId: map['taskId'] as String,
      executedBy: map['executedBy'] as String,
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      finishedAt: (map['finishedAt'] as Timestamp?)?.toDate(),
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
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      notes: entity.notes,
      photoUrl: entity.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'occurrenceId': occurrenceId,
      'taskId': taskId,
      'executedBy': executedBy,
      'startedAt': Timestamp.fromDate(startedAt),
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
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
      startedAt: startedAt,
      finishedAt: finishedAt,
      notes: notes,
      photoUrl: photoUrl,
    );
  }
}
