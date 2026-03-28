import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
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

  const TaskEntity({
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

  TaskEntity copyWith({
    String? id,
    String? pairId,
    String? title,
    String? description,
    String? assignedTo,
    int? points,
    bool? isActive,
    String? recurrenceId,
    String? scheduledStartTime,
    int? expectedDuration,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pairId,
        title,
        description,
        assignedTo,
        points,
        isActive,
        recurrenceId,
        scheduledStartTime,
        expectedDuration,
        createdAt,
        createdBy,
      ];
}
