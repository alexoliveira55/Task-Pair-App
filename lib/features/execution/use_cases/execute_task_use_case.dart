import '../../../domain/entities/task_execution_entity.dart';
import '../../../domain/repositories/task_execution_repository.dart';
import '../../../domain/repositories/task_occurrence_repository.dart';
import '../../../core/constants/app_constants.dart';

class ExecuteTaskUseCase {
  final TaskExecutionRepository _executionRepository;
  final TaskOccurrenceRepository _occurrenceRepository;

  ExecuteTaskUseCase(this._executionRepository, this._occurrenceRepository);

  Future<TaskExecutionEntity> execute({
    required String occurrenceId,
    required String taskId,
    required String executedBy,
    String? notes,
    String? photoUrl,
  }) async {
    final execution = await _executionRepository.createExecution(
      TaskExecutionEntity(
        id: '',
        occurrenceId: occurrenceId,
        taskId: taskId,
        executedBy: executedBy,
        executedAt: DateTime.now(),
        notes: notes,
        photoUrl: photoUrl,
      ),
    );

    await _occurrenceRepository.updateOccurrenceStatus(
        occurrenceId, AppConstants.executedStatus);

    return execution;
  }
}
