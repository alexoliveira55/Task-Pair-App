import '../entities/task_recurrence_entity.dart';

abstract class TaskRecurrenceRepository {
  Future<TaskRecurrenceEntity?> getRecurrenceById(String id);
  Future<TaskRecurrenceEntity?> getRecurrenceByTaskId(String taskId);
  Future<TaskRecurrenceEntity> createRecurrence(TaskRecurrenceEntity recurrence);
  Future<void> updateRecurrence(TaskRecurrenceEntity recurrence);
  Future<void> deactivateRecurrence(String id);
}
