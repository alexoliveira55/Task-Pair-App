import '../entities/task_execution_entity.dart';

abstract class TaskExecutionRepository {
  Future<TaskExecutionEntity?> getExecutionById(String id);
  Future<TaskExecutionEntity?> getExecutionByOccurrenceId(String occurrenceId);
  Future<TaskExecutionEntity> createExecution(TaskExecutionEntity execution);
  Future<void> updateExecution(TaskExecutionEntity execution);
  Stream<List<TaskExecutionEntity>> watchExecutionsByTaskId(String taskId);
}
