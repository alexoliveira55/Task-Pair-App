import '../entities/task_validation_entity.dart';

abstract class TaskValidationRepository {
  Future<TaskValidationEntity?> getValidationById(String id);
  Future<TaskValidationEntity?> getValidationByExecutionId(String executionId);
  Future<TaskValidationEntity> createValidation(TaskValidationEntity validation);
  Stream<List<TaskValidationEntity>> watchValidationsByPairId(String pairId);
}
