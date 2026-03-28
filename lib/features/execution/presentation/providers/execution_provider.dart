import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/task_execution_repository_impl.dart';
import 'package:task_pair_app/domain/entities/task_execution_entity.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
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
  final TaskExecutionRepositoryImpl _executionRepository;
  final Ref _ref;

  ExecutionNotifier(
      this._executeTaskUseCase, this._executionRepository, this._ref)
      : super(const AsyncValue.data(null));

  /// Step 1: Start task execution — records startedAt, sets occurrence to in_progress.
  Future<TaskExecutionEntity?> startExecution({
    required String occurrenceId,
    required String taskId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      final execution = await _executeTaskUseCase.startExecution(
        occurrenceId: occurrenceId,
        taskId: taskId,
        executedBy: currentUser.id,
      );
      state = const AsyncValue.data(null);
      return execution;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Step 2: Finish task execution — records finishedAt + notes, sets occurrence to executed.
  Future<TaskExecutionEntity?> finishExecution({
    required String executionId,
    required String occurrenceId,
    String? notes,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Fetch the execution entity by ID to pass to the use case
      final execution =
          await _executionRepository.getExecutionById(executionId);
      if (execution == null) throw Exception('Execution not found');

      final result = await _executeTaskUseCase.finishExecution(
        executionId: executionId,
        execution: execution,
        notes: notes,
        photoUrl: photoUrl,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final executionNotifierProvider =
    StateNotifierProvider<ExecutionNotifier, AsyncValue<void>>((ref) {
  return ExecutionNotifier(
    ref.watch(executeTaskUseCaseProvider),
    ref.watch(taskExecutionRepositoryProvider),
    ref,
  );
});

final executedOccurrencesProvider = Provider((ref) {
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) => o.status == AppConstants.executedStatus)
      .toList();
});

/// Occurrences assigned to the current user with status 'pending' or 'in_progress'.
final myPendingOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences = ref.watch(pendingOccurrencesProvider);
  return occurrences.where((o) => o.assignedTo == currentUser.id).toList();
});

/// Occurrences assigned to the current user with status 'in_progress'.
final myInProgressOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.inProgressStatus)
      .toList();
});

/// Occurrences assigned to the current user with status 'executed' (awaiting validation).
final myExecutedOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.executedStatus)
      .toList();
});

/// Occurrences assigned to the current user with status 'validated'.
final myValidatedOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.validatedStatus)
      .toList();
});

// ── Pair-scoped family providers (for dashboard per-pair cards) ──

/// Pending occurrences for the current user within a specific pair.
final myPendingByPairProvider =
    Provider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences =
      ref.watch(occurrencesByPairIdProvider(pairId)).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.pendingStatus)
      .toList();
});

/// In-progress occurrences for the current user within a specific pair.
final myInProgressByPairProvider =
    Provider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences =
      ref.watch(occurrencesByPairIdProvider(pairId)).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.inProgressStatus)
      .toList();
});

/// Executed occurrences for the current user within a specific pair.
final myExecutedByPairProvider =
    Provider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences =
      ref.watch(occurrencesByPairIdProvider(pairId)).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.executedStatus)
      .toList();
});

/// Validated occurrences for the current user within a specific pair.
final myValidatedByPairProvider =
    Provider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final occurrences =
      ref.watch(occurrencesByPairIdProvider(pairId)).value ?? [];
  return occurrences
      .where((o) =>
          o.assignedTo == currentUser.id &&
          o.status == AppConstants.validatedStatus)
      .toList();
});

/// Fetches a single execution by its ID from Firestore.
final executionByIdProvider =
    FutureProvider.family<TaskExecutionEntity?, String>((ref, executionId) {
  final repo = ref.watch(taskExecutionRepositoryProvider);
  return repo.getExecutionById(executionId);
});

/// Fetches the execution record for a given occurrence ID.
final executionByOccurrenceIdProvider =
    FutureProvider.family<TaskExecutionEntity?, String>((ref, occurrenceId) {
  final repo = ref.watch(taskExecutionRepositoryProvider);
  return repo.getExecutionByOccurrenceId(occurrenceId);
});
