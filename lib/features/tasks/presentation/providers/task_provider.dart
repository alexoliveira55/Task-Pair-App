import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/task_recurrence_repository_impl.dart';
import 'package:task_pair_app/data/repositories/task_repository_impl.dart';
import 'package:task_pair_app/domain/entities/task_entity.dart';
import 'package:task_pair_app/domain/entities/task_recurrence_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';
import 'package:task_pair_app/features/recurrence/use_cases/generate_occurrences_use_case.dart';
import 'package:task_pair_app/features/recurrence/presentation/providers/recurrence_provider.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepositoryImpl(ref.watch(firestoreProvider));
});

final taskRecurrenceRepositoryProvider = Provider((ref) {
  return TaskRecurrenceRepositoryImpl(ref.watch(firestoreProvider));
});

final tasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final pair = ref.watch(currentPairProvider);
  if (pair == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).watchTasksByPairId(pair.id);
});

/// Pair-scoped: streams tasks for a specific pair.
final tasksByPairIdProvider =
    StreamProvider.family<List<TaskEntity>, String>((ref, pairId) {
  // Guard: don't start Firestore streams until auth is confirmed
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).watchTasksByPairId(pairId);
});

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepositoryImpl _taskRepository;
  final TaskRecurrenceRepositoryImpl _recurrenceRepository;
  final GenerateOccurrencesUseCase _generateOccurrencesUseCase;
  final Ref _ref;

  TaskNotifier(
    this._taskRepository,
    this._recurrenceRepository,
    this._generateOccurrencesUseCase,
    this._ref,
  ) : super(const AsyncValue.data(null));

  Future<void> createTask({
    required String title,
    String? description,
    required int points,
    required String recurrenceType,
    String? scheduledStartTime,
    int? expectedDuration,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    int? intervalDays,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      final currentPair = _ref.read(currentPairProvider);
      if (currentUser == null) throw Exception('Not authenticated');
      if (currentPair == null) throw Exception('No pair found');

      // Requester creates task, auto-assigns to executor of the pair
      final task = await _taskRepository.createTask(TaskEntity(
        id: '',
        pairId: currentPair.id,
        title: title,
        description: description,
        assignedTo: currentPair.executorId,
        points: points,
        isActive: true,
        scheduledStartTime: scheduledStartTime,
        expectedDuration: expectedDuration,
        createdAt: DateTime.now(),
        createdBy: currentUser.id,
      ));

      if (recurrenceType != AppConstants.onceRecurrence) {
        final recurrence = await _recurrenceRepository.createRecurrence(
          TaskRecurrenceEntity(
            id: '',
            taskId: task.id,
            type: recurrenceType,
            daysOfWeek: daysOfWeek,
            dayOfMonth: dayOfMonth,
            intervalDays: intervalDays,
            startDate: DateTime.now(),
            endDate: endDate,
            isActive: true,
          ),
        );
        await _taskRepository
            .updateTask(task.copyWith(recurrenceId: recurrence.id));

        // Generate occurrences for the recurrence
        await _generateOccurrencesUseCase.execute(
          recurrence: recurrence,
          pairId: currentPair.id,
          assignedTo: currentPair.executorId,
          scheduledStartTime: scheduledStartTime,
          expectedDuration: expectedDuration,
        );
      } else {
        // For once-type tasks, create a single occurrence
        await _generateOccurrencesUseCase.execute(
          recurrence: TaskRecurrenceEntity(
            id: '',
            taskId: task.id,
            type: AppConstants.onceRecurrence,
            startDate: DateTime.now(),
            isActive: true,
          ),
          pairId: currentPair.id,
          assignedTo: currentPair.executorId,
          scheduledStartTime: scheduledStartTime,
          expectedDuration: expectedDuration,
        );
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(TaskEntity task) async {
    state = const AsyncValue.loading();
    try {
      await _taskRepository.updateTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      await _taskRepository.deleteTask(taskId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final generateOccurrencesUseCaseProvider = Provider((ref) {
  return GenerateOccurrencesUseCase(
    ref.watch(taskOccurrenceRepositoryProvider),
  );
});

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  return TaskNotifier(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskRecurrenceRepositoryProvider),
    ref.watch(generateOccurrencesUseCaseProvider),
    ref,
  );
});

/// Provides a single task by ID, derived from the tasks stream.
final taskByIdProvider = Provider.family<TaskEntity?, String>((ref, taskId) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  try {
    return tasks.firstWhere((t) => t.id == taskId);
  } catch (_) {
    return null;
  }
});
