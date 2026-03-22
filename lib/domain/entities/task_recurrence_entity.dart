import 'package:equatable/equatable.dart';

class TaskRecurrenceEntity extends Equatable {
  final String id;
  final String taskId;
  final String type; // daily, weekly, monthly, once
  final List<int>? daysOfWeek; // 1=Monday ... 7=Sunday
  final int? dayOfMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const TaskRecurrenceEntity({
    required this.id,
    required this.taskId,
    required this.type,
    this.daysOfWeek,
    this.dayOfMonth,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  TaskRecurrenceEntity copyWith({
    String? id,
    String? taskId,
    String? type,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return TaskRecurrenceEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, taskId, type, daysOfWeek, dayOfMonth, startDate, endDate, isActive];
}
