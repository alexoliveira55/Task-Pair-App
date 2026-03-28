import '../../../domain/entities/task_validation_entity.dart';
import '../../../domain/repositories/task_validation_repository.dart';
import '../../../domain/repositories/task_occurrence_repository.dart';
import '../../../domain/repositories/score_repository.dart';
import '../../../core/constants/app_constants.dart';

class ValidateTaskUseCase {
  final TaskValidationRepository _validationRepository;
  final TaskOccurrenceRepository _occurrenceRepository;
  final ScoreRepository _scoreRepository;

  ValidateTaskUseCase(
    this._validationRepository,
    this._occurrenceRepository,
    this._scoreRepository,
  );

  /// Validates with a percentage (0-100).
  /// Score formula: taskPoints * percentage / 100
  /// If percentage == 0 (não cumprida): score = taskPoints * -1
  Future<TaskValidationEntity> execute({
    required String executionId,
    required String occurrenceId,
    required String validatedBy,
    required int percentage,
    String? feedback,
    required String pairId,
    required int taskPoints,
    required String executedBy,
  }) async {
    final validation = await _validationRepository.createValidation(
      TaskValidationEntity(
        id: '',
        executionId: executionId,
        occurrenceId: occurrenceId,
        validatedBy: validatedBy,
        validatedAt: DateTime.now(),
        percentage: percentage,
        feedback: feedback,
      ),
    );

    final newStatus = percentage > 0
        ? AppConstants.validatedStatus
        : AppConstants.missedStatus;
    await _occurrenceRepository.updateOccurrenceStatus(occurrenceId, newStatus);

    // Score formula: percentage > 0 → taskPoints * percentage / 100
    //                percentage == 0 (não cumprida) → taskPoints * -1
    final int calculatedPoints;
    if (percentage > 0) {
      calculatedPoints = (taskPoints * percentage / 100).round();
    } else {
      calculatedPoints = taskPoints * -1;
    }

    await _scoreRepository.addPoints(executedBy, pairId, calculatedPoints);

    return validation;
  }
}
