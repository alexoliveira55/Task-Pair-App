import '../../../domain/entities/task_validation_entity.dart';
import '../../../domain/repositories/task_validation_repository.dart';
import '../../../domain/repositories/task_occurrence_repository.dart';
import '../../../domain/repositories/score_repository.dart';
import '../../../domain/repositories/task_execution_repository.dart';
import '../../../core/constants/app_constants.dart';

class ValidateTaskUseCase {
  final TaskValidationRepository _validationRepository;
  final TaskOccurrenceRepository _occurrenceRepository;
  final TaskExecutionRepository _executionRepository;
  final ScoreRepository _scoreRepository;

  ValidateTaskUseCase(
    this._validationRepository,
    this._occurrenceRepository,
    this._executionRepository,
    this._scoreRepository,
  );

  Future<TaskValidationEntity> execute({
    required String executionId,
    required String occurrenceId,
    required String validatedBy,
    required bool isApproved,
    String? feedback,
    required String pairId,
    required int points,
    required String executedBy,
  }) async {
    final validation = await _validationRepository.createValidation(
      TaskValidationEntity(
        id: '',
        executionId: executionId,
        occurrenceId: occurrenceId,
        validatedBy: validatedBy,
        validatedAt: DateTime.now(),
        isApproved: isApproved,
        feedback: feedback,
      ),
    );

    final newStatus =
        isApproved ? AppConstants.validatedStatus : AppConstants.rejectedStatus;
    await _occurrenceRepository.updateOccurrenceStatus(occurrenceId, newStatus);

    if (isApproved) {
      await _scoreRepository.addPoints(executedBy, pairId, points);
    }

    return validation;
  }
}
