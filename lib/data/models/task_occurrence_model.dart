import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_occurrence_entity.dart';

class TaskOccurrenceModel {
  final String id;
  final String taskId;
  final String pairId;
  final DateTime dueDate;
  final String? scheduledStartTime;
  final int? expectedDuration;
  final String status;
  final String? assignedTo;
  final String? executionId;

  const TaskOccurrenceModel({
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

  factory TaskOccurrenceModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskOccurrenceModel(
      id: id,
      taskId: map['taskId'] as String,
      pairId: map['pairId'] as String,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      scheduledStartTime: map['scheduledStartTime'] as String?,
      expectedDuration: (map['expectedDuration'] as num?)?.toInt(),
      status: map['status'] as String,
      assignedTo: map['assignedTo'] as String?,
      executionId: map['executionId'] as String?,
    );
  }

  factory TaskOccurrenceModel.fromEntity(TaskOccurrenceEntity entity) {
    return TaskOccurrenceModel(
      id: entity.id,
      taskId: entity.taskId,
      pairId: entity.pairId,
      dueDate: entity.dueDate,
      scheduledStartTime: entity.scheduledStartTime,
      expectedDuration: entity.expectedDuration,
      status: entity.status,
      assignedTo: entity.assignedTo,
      executionId: entity.executionId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'pairId': pairId,
      'dueDate': Timestamp.fromDate(dueDate),
      'scheduledStartTime': scheduledStartTime,
      'expectedDuration': expectedDuration,
      'status': status,
      'assignedTo': assignedTo,
      'executionId': executionId,
    };
  }

  TaskOccurrenceEntity toEntity() {
    return TaskOccurrenceEntity(
      id: id,
      taskId: taskId,
      pairId: pairId,
      dueDate: dueDate,
      scheduledStartTime: scheduledStartTime,
      expectedDuration: expectedDuration,
      status: status,
      assignedTo: assignedTo,
      executionId: executionId,
    );
  }
}
