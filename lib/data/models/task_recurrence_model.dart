import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_recurrence_entity.dart';

class TaskRecurrenceModel {
  final String id;
  final String taskId;
  final String type;
  final List<int>? daysOfWeek;
  final int? dayOfMonth;
  final int? intervalDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const TaskRecurrenceModel({
    required this.id,
    required this.taskId,
    required this.type,
    this.daysOfWeek,
    this.dayOfMonth,
    this.intervalDays,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory TaskRecurrenceModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskRecurrenceModel(
      id: id,
      taskId: map['taskId'] as String,
      type: map['type'] as String,
      daysOfWeek: (map['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      dayOfMonth: (map['dayOfMonth'] as num?)?.toInt(),
      intervalDays: (map['intervalDays'] as num?)?.toInt(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  factory TaskRecurrenceModel.fromEntity(TaskRecurrenceEntity entity) {
    return TaskRecurrenceModel(
      id: entity.id,
      taskId: entity.taskId,
      type: entity.type,
      daysOfWeek: entity.daysOfWeek,
      dayOfMonth: entity.dayOfMonth,
      intervalDays: entity.intervalDays,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'type': type,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'intervalDays': intervalDays,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
    };
  }

  TaskRecurrenceEntity toEntity() {
    return TaskRecurrenceEntity(
      id: id,
      taskId: taskId,
      type: type,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      intervalDays: intervalDays,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
    );
  }
}
