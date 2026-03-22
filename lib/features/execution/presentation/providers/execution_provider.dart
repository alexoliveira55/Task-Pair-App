import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/task_execution_repository_impl.dart';
import 'package:task_pair_app/domain/entities/task_execution_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/execution/use_cases/execute_task_use_case.dart';
import 'package:task_pair_app/features/recurrence/presentation/providers/recurrence_provider.dart';

final taskExecutionRepositoryProvider = Provider((ref) {
  return TaskExecutionRepositoryImpl(ref.watch(firestoreProvider));
});

final executeTaskUseCaseProvider = Provider((ref) {
  return ExecuteTaskUseCase(
    ref.watch(taskExecutionRepositoryProvider),
    ref.watch(taskOccurrenceRepositoryProvider),
  );
});

class ExecutionNotifier extends StateNotifier<AsyncValue<void>> {
  final ExecuteTaskUseCase _executeTaskUseCase;
  final Ref _ref;

  ExecutionNotifier(this._executeTaskUseCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<TaskExecutionEntity?> executeTask({
    required String occurrenceId,
    required String taskId,
    String? notes,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      final execution = await _executeTaskUseCase.execute(
        occurrenceId: occurrenceId,
        taskId: taskId,
        executedBy: currentUser.id,
        notes: notes,
        photoUrl: photoUrl,
      );
      state = const AsyncValue.data(null);
      return execution;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final executionNotifierProvider =
    StateNotifierProvider<ExecutionNotifier, AsyncValue<void>>((ref) {
  return ExecutionNotifier(ref.watch(executeTaskUseCaseProvider), ref);
});

final executedOccurrencesProvider = Provider((ref) {
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) => o.status == AppConstants.executedStatus)
      .toList();
});

/// Fetches a single execution by its ID from Firestore.
final executionByIdProvider =
    FutureProvider.family<TaskExecutionEntity?, String>((ref, executionId) {
  final repo = ref.watch(taskExecutionRepositoryProvider);
  return repo.getExecutionById(executionId);
});
