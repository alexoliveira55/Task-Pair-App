import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/task_recurrence_repository.dart';
import '../../../domain/entities/task_recurrence_entity.dart';
import '../../../core/constants/app_constants.dart';

class CreateTaskUseCase {
  final TaskRepository _taskRepository;
  final TaskRecurrenceRepository _recurrenceRepository;

  CreateTaskUseCase(this._taskRepository, this._recurrenceRepository);

  Future<TaskEntity> execute({
    required String pairId,
    required String title,
    String? description,
    String? assignedTo,
    required int points,
    required String createdBy,
    required String recurrenceType,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
  }) async {
    final task = await _taskRepository.createTask(TaskEntity(
      id: '',
      pairId: pairId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      points: points,
      isActive: true,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    ));

    if (recurrenceType != AppConstants.onceRecurrence) {
      final recurrence = await _recurrenceRepository.createRecurrence(
        TaskRecurrenceEntity(
          id: '',
          taskId: task.id,
          type: recurrenceType,
          daysOfWeek: daysOfWeek,
          dayOfMonth: dayOfMonth,
          startDate: DateTime.now(),
          endDate: endDate,
          isActive: true,
        ),
      );
      return task.copyWith(recurrenceId: recurrence.id);
    }

    return task;
  }
}
