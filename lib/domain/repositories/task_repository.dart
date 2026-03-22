import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<TaskEntity?> getTaskById(String id);
  Future<List<TaskEntity>> getTasksByPairId(String pairId);
  Future<TaskEntity> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Stream<List<TaskEntity>> watchTasksByPairId(String pairId);
}
