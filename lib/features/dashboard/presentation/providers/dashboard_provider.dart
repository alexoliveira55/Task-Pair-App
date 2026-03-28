import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/domain/entities/task_entity.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';
import 'package:task_pair_app/features/recurrence/presentation/providers/recurrence_provider.dart';
import 'package:task_pair_app/features/score/presentation/providers/score_provider.dart';
import 'package:task_pair_app/features/tasks/presentation/providers/task_provider.dart';

final dashboardDataProvider = Provider((ref) {
  final pair = ref.watch(currentPairProvider);
  final scores = ref.watch(scoresProvider).value ?? [];
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  final tasks = ref.watch(tasksProvider).value ?? [];
  final thermometerProgress = ref.watch(thermometerProgressProvider);
  final myPoints = ref.watch(myPointsProvider);

  final pendingOccurrences =
      occurrences.where((o) => o.status == 'pending').toList();
  final todayOccurrences = occurrences
      .where((o) =>
          o.dueDate.day == DateTime.now().day &&
          o.dueDate.month == DateTime.now().month &&
          o.dueDate.year == DateTime.now().year)
      .toList();

  return DashboardData(
    pair: pair,
    scores: scores,
    totalPoints: myPoints,
    thermometerProgress: thermometerProgress,
    totalTasks: tasks.length,
    pendingCount: pendingOccurrences.length,
    todayCount: todayOccurrences.length,
  );
});

class DashboardData {
  final dynamic pair;
  final List scores;
  final int totalPoints;
  final double thermometerProgress;
  final int totalTasks;
  final int pendingCount;
  final int todayCount;

  const DashboardData({
    required this.pair,
    required this.scores,
    required this.totalPoints,
    required this.thermometerProgress,
    required this.totalTasks,
    required this.pendingCount,
    required this.todayCount,
  });
}

/// Tasks created by the current user (requester view).
final myRequestedTasksProvider = Provider<List<TaskEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.createdBy == currentUser.id).toList();
});

/// Tasks assigned to the current user (executor view).
final myAssignedTasksProvider = Provider<List<TaskEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.assignedTo == currentUser.id).toList();
});

/// Occurrences for tasks I created that are 'executed' (need my validation).
final pendingValidationOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final myRequestedTasks = ref.watch(myRequestedTasksProvider);
  final myTaskIds = myRequestedTasks.map((t) => t.id).toSet();
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) =>
          myTaskIds.contains(o.taskId) &&
          o.status == AppConstants.executedStatus)
      .toList();
});

// ── Pair-scoped family providers (for dashboard per-pair cards) ──

/// Tasks created by the current user within a specific pair.
final myRequestedTasksByPairProvider =
    Provider.family<List<TaskEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final tasks = ref.watch(tasksByPairIdProvider(pairId)).value ?? [];
  return tasks.where((t) => t.createdBy == currentUser.id).toList();
});

/// Executed occurrences for tasks I created within a specific pair (need validation).
final pendingValidationByPairProvider =
    Provider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final tasks = ref.watch(tasksByPairIdProvider(pairId)).value ?? [];
  final myTaskIds = tasks
      .where((t) => t.createdBy == currentUser.id)
      .map((t) => t.id)
      .toSet();
  final occurrences =
      ref.watch(occurrencesByPairIdProvider(pairId)).value ?? [];
  return occurrences
      .where((o) =>
          myTaskIds.contains(o.taskId) &&
          o.status == AppConstants.executedStatus)
      .toList();
});
