import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository _taskRepository;

  UpdateTaskUseCase(this._taskRepository);

  Future<void> execute(TaskEntity task) async {
    await _taskRepository.updateTask(task);
  }
}
