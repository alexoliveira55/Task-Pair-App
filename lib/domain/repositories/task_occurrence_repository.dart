import '../entities/task_occurrence_entity.dart';

abstract class TaskOccurrenceRepository {
  Future<TaskOccurrenceEntity?> getOccurrenceById(String id);
  Future<List<TaskOccurrenceEntity>> getOccurrencesByPairId(String pairId);
  Future<List<TaskOccurrenceEntity>> getOccurrencesByTaskId(String taskId);
  Future<List<TaskOccurrenceEntity>> getPendingOccurrences(String pairId);
  Future<List<TaskOccurrenceEntity>> getOccurrencesByStatus(
      String pairId, String status);
  Future<TaskOccurrenceEntity> createOccurrence(
      TaskOccurrenceEntity occurrence);
  Future<void> updateOccurrenceStatus(String id, String status);
  Stream<List<TaskOccurrenceEntity>> watchOccurrencesByPairId(String pairId);
}
