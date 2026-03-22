import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _taskRepository;

  GetTasksUseCase(this._taskRepository);

  Future<List<TaskEntity>> execute(String pairId) async {
    return _taskRepository.getTasksByPairId(pairId);
  }

  Stream<List<TaskEntity>> watch(String pairId) {
    return _taskRepository.watchTasksByPairId(pairId);
  }
}
