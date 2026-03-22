import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../data/repositories/task_repository_impl.dart';
import '../../../data/repositories/task_recurrence_repository_impl.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/task_recurrence_entity.dart';
import '../../../core/constants/app_constants.dart';

final taskRepositoryProvider = Provider((ref) {
  return TaskRepositoryImpl(ref.watch(firestoreProvider));
});

final taskRecurrenceRepositoryProvider = Provider((ref) {
  return TaskRecurrenceRepositoryImpl(ref.watch(firestoreProvider));
});

final tasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final pairAsync = ref.watch(currentPairProvider);
  return pairAsync.when(
    data: (pair) {
      if (pair == null) return Stream.value([]);
      return ref.watch(taskRepositoryProvider).watchTasksByPairId(pair.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepositoryImpl _taskRepository;
  final TaskRecurrenceRepositoryImpl _recurrenceRepository;
  final Ref _ref;

  TaskNotifier(this._taskRepository, this._recurrenceRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createTask({
    required String title,
    String? description,
    String? assignedTo,
    required int points,
    required String recurrenceType,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      final currentPair = _ref.read(currentPairProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');
      if (currentPair == null) throw Exception('No pair found');

      final task = await _taskRepository.createTask(TaskEntity(
        id: '',
        pairId: currentPair.id,
        title: title,
        description: description,
        assignedTo: assignedTo,
        points: points,
        isActive: true,
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
            startDate: DateTime.now(),
            endDate: endDate,
            isActive: true,
          ),
        );
        await _taskRepository.updateTask(task.copyWith(recurrenceId: recurrence.id));
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

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  return TaskNotifier(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskRecurrenceRepositoryProvider),
    ref,
  );
});
