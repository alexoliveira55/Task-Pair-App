import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/features/recurrence/presentation/providers/recurrence_provider.dart';
import 'package:task_pair_app/features/score/presentation/providers/score_provider.dart';
import 'package:task_pair_app/features/tasks/presentation/providers/task_provider.dart';

final reportsProvider = Provider((ref) {
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  final scores = ref.watch(scoresProvider).value ?? [];
  final tasks = ref.watch(tasksProvider).value ?? [];

  final completed = occurrences.where((o) => o.status == 'validated').toList();
  final missed = occurrences.where((o) => o.status == 'missed').toList();
  final pending = occurrences.where((o) => o.status == 'pending').toList();

  return ReportData(
    occurrences: occurrences,
    completedOccurrences: completed,
    missedOccurrences: missed,
    pendingOccurrences: pending,
    scores: scores,
    totalTasks: tasks.length,
    completionRate:
        occurrences.isEmpty ? 0.0 : completed.length / occurrences.length,
  );
});

class ReportData {
  final List<TaskOccurrenceEntity> occurrences;
  final List<TaskOccurrenceEntity> completedOccurrences;
  final List<TaskOccurrenceEntity> missedOccurrences;
  final List<TaskOccurrenceEntity> pendingOccurrences;
  final List<ScoreEntity> scores;
  final int totalTasks;
  final double completionRate;

  const ReportData({
    required this.occurrences,
    required this.completedOccurrences,
    required this.missedOccurrences,
    required this.pendingOccurrences,
    required this.scores,
    required this.totalTasks,
    required this.completionRate,
  });
}
