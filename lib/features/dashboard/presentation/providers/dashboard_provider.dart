import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../features/score/presentation/providers/score_provider.dart';
import '../../../features/recurrence/presentation/providers/recurrence_provider.dart';
import '../../../features/tasks/presentation/providers/task_provider.dart';

final dashboardDataProvider = Provider((ref) {
  final pair = ref.watch(currentPairProvider).value;
  final scores = ref.watch(scoresProvider).value ?? [];
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  final tasks = ref.watch(tasksProvider).value ?? [];
  final thermometerProgress = ref.watch(thermometerProgressProvider);
  final totalPoints = ref.watch(totalPairPointsProvider);

  final pendingOccurrences =
      occurrences.where((o) => o.status == 'pending').toList();
  final todayOccurrences = occurrences
      .where((o) => o.dueDate.day == DateTime.now().day &&
          o.dueDate.month == DateTime.now().month &&
          o.dueDate.year == DateTime.now().year)
      .toList();

  return DashboardData(
    pair: pair,
    scores: scores,
    totalPoints: totalPoints,
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
