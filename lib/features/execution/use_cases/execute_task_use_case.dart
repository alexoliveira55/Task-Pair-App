import '../../../domain/entities/task_execution_entity.dart';
import '../../../domain/repositories/task_execution_repository.dart';
import '../../../domain/repositories/task_occurrence_repository.dart';
import '../../../core/constants/app_constants.dart';

class ExecuteTaskUseCase {
  final TaskExecutionRepository _executionRepository;
  final TaskOccurrenceRepository _occurrenceRepository;

  ExecuteTaskUseCase(this._executionRepository, this._occurrenceRepository);

  /// Step 1: Start execution — creates execution record with startedAt, sets occurrence to in_progress.
  Future<TaskExecutionEntity> startExecution({
    required String occurrenceId,
    required String taskId,
    required String executedBy,
  }) async {
    final execution = await _executionRepository.createExecution(
      TaskExecutionEntity(
        id: '',
        occurrenceId: occurrenceId,
        taskId: taskId,
        executedBy: executedBy,
        startedAt: DateTime.now(),
      ),
    );

    await _occurrenceRepository.updateOccurrenceStatus(
        occurrenceId, AppConstants.inProgressStatus);
    await _occurrenceRepository.updateOccurrenceExecutionId(
        occurrenceId, execution.id);

    return execution;
  }

  /// Step 2: Finish execution — updates execution with finishedAt and notes, sets occurrence to executed.
  Future<TaskExecutionEntity> finishExecution({
    required String executionId,
    required TaskExecutionEntity execution,
    String? notes,
    String? photoUrl,
  }) async {
    final updated = execution.copyWith(
      finishedAt: DateTime.now(),
      notes: notes,
      photoUrl: photoUrl,
    );

    await _executionRepository.updateExecution(updated);
    await _occurrenceRepository.updateOccurrenceStatus(
        execution.occurrenceId, AppConstants.executedStatus);

    return updated;
  }
}
