import '../repositories/task_repository.dart';
import '../repositories/task_recurrence_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _taskRepository;
  final TaskRecurrenceRepository _recurrenceRepository;

  DeleteTaskUseCase(this._taskRepository, this._recurrenceRepository);

  Future<void> execute({
    required String taskId,
    String? recurrenceId,
  }) async {
    if (recurrenceId != null) {
      await _recurrenceRepository.deactivateRecurrence(recurrenceId);
    }
    await _taskRepository.deleteTask(taskId);
  }
}
