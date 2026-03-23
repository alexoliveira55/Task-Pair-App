import '../entities/task_entity.dart';
import '../entities/task_recurrence_entity.dart';
import '../repositories/task_repository.dart';
import '../repositories/task_recurrence_repository.dart';

class GetTaskDetailsUseCase {
  final TaskRepository _taskRepository;
  final TaskRecurrenceRepository _recurrenceRepository;

  GetTaskDetailsUseCase(this._taskRepository, this._recurrenceRepository);

  Future<({TaskEntity task, TaskRecurrenceEntity? recurrence})> execute(
      String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    TaskRecurrenceEntity? recurrence;
    if (task.recurrenceId != null) {
      recurrence =
          await _recurrenceRepository.getRecurrenceById(task.recurrenceId!);
    }

    return (task: task, recurrence: recurrence);
  }
}
