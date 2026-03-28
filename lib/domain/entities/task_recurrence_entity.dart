import 'package:equatable/equatable.dart';

class TaskRecurrenceEntity extends Equatable {
  final String id;
  final String taskId;
  final String type; // daily, weekly, monthly, interval, once
  final List<int>? daysOfWeek; // 1=Monday ... 7=Sunday
  final int? dayOfMonth;
  final int? intervalDays; // for interval recurrence (every X days)
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const TaskRecurrenceEntity({
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

  TaskRecurrenceEntity copyWith({
    String? id,
    String? taskId,
    String? type,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    int? intervalDays,
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
      intervalDays: intervalDays ?? this.intervalDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        type,
        daysOfWeek,
        dayOfMonth,
        intervalDays,
        startDate,
        endDate,
        isActive
      ];
}
