import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_occurrence_entity.dart';

class TaskOccurrenceModel {
  final String id;
  final String taskId;
  final String pairId;
  final DateTime dueDate;
  final String status;
  final String? assignedTo;

  const TaskOccurrenceModel({
    required this.id,
    required this.taskId,
    required this.pairId,
    required this.dueDate,
    required this.status,
    this.assignedTo,
  });

  factory TaskOccurrenceModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskOccurrenceModel(
      id: id,
      taskId: map['taskId'] as String,
      pairId: map['pairId'] as String,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: map['status'] as String,
      assignedTo: map['assignedTo'] as String?,
    );
  }

  factory TaskOccurrenceModel.fromEntity(TaskOccurrenceEntity entity) {
    return TaskOccurrenceModel(
      id: entity.id,
      taskId: entity.taskId,
      pairId: entity.pairId,
      dueDate: entity.dueDate,
      status: entity.status,
      assignedTo: entity.assignedTo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'pairId': pairId,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'assignedTo': assignedTo,
    };
  }

  TaskOccurrenceEntity toEntity() {
    return TaskOccurrenceEntity(
      id: id,
      taskId: taskId,
      pairId: pairId,
      dueDate: dueDate,
      status: status,
      assignedTo: assignedTo,
    );
  }
}
