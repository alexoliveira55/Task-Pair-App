import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel {
  final String id;
  final String pairId;
  final String title;
  final String? description;
  final String? assignedTo;
  final int points;
  final bool isActive;
  final String? recurrenceId;
  final String? scheduledStartTime;
  final int? expectedDuration;
  final DateTime createdAt;
  final String createdBy;

  const TaskModel({
    required this.id,
    required this.pairId,
    required this.title,
    this.description,
    this.assignedTo,
    required this.points,
    required this.isActive,
    this.recurrenceId,
    this.scheduledStartTime,
    this.expectedDuration,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      pairId: map['pairId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      assignedTo: map['assignedTo'] as String?,
      points: (map['points'] as num).toInt(),
      isActive: map['isActive'] as bool? ?? true,
      recurrenceId: map['recurrenceId'] as String?,
      scheduledStartTime: map['scheduledStartTime'] as String?,
      expectedDuration: (map['expectedDuration'] as num?)?.toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      pairId: entity.pairId,
      title: entity.title,
      description: entity.description,
      assignedTo: entity.assignedTo,
      points: entity.points,
      isActive: entity.isActive,
      recurrenceId: entity.recurrenceId,
      scheduledStartTime: entity.scheduledStartTime,
      expectedDuration: entity.expectedDuration,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pairId': pairId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'points': points,
      'isActive': isActive,
      'recurrenceId': recurrenceId,
      'scheduledStartTime': scheduledStartTime,
      'expectedDuration': expectedDuration,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      pairId: pairId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      points: points,
      isActive: isActive,
      recurrenceId: recurrenceId,
      scheduledStartTime: scheduledStartTime,
      expectedDuration: expectedDuration,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
