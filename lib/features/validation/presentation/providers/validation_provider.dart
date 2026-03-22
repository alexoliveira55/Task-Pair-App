import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../data/repositories/task_validation_repository_impl.dart';
import '../../../features/recurrence/presentation/providers/recurrence_provider.dart';
import '../../../features/execution/presentation/providers/execution_provider.dart';
import '../../../features/score/presentation/providers/score_provider.dart';
import '../use_cases/validate_task_use_case.dart';

final taskValidationRepositoryProvider = Provider((ref) {
  return TaskValidationRepositoryImpl(ref.watch(firestoreProvider));
});

final validateTaskUseCaseProvider = Provider((ref) {
  return ValidateTaskUseCase(
    ref.watch(taskValidationRepositoryProvider),
    ref.watch(taskOccurrenceRepositoryProvider),
    ref.watch(taskExecutionRepositoryProvider),
    ref.watch(scoreRepositoryProvider),
  );
});

class ValidationNotifier extends StateNotifier<AsyncValue<void>> {
  final ValidateTaskUseCase _validateTaskUseCase;
  final Ref _ref;

  ValidationNotifier(this._validateTaskUseCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> validate({
    required String executionId,
    required String occurrenceId,
    required bool isApproved,
    String? feedback,
    required String pairId,
    required int points,
    required String executedBy,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      await _validateTaskUseCase.execute(
        executionId: executionId,
        occurrenceId: occurrenceId,
        validatedBy: currentUser.id,
        isApproved: isApproved,
        feedback: feedback,
        pairId: pairId,
        points: points,
        executedBy: executedBy,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final validationNotifierProvider =
    StateNotifierProvider<ValidationNotifier, AsyncValue<void>>((ref) {
  return ValidationNotifier(ref.watch(validateTaskUseCaseProvider), ref);
});
