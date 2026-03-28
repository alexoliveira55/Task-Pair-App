import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/task_occurrence_repository_impl.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';

final taskOccurrenceRepositoryProvider = Provider((ref) {
  return TaskOccurrenceRepositoryImpl(ref.watch(firestoreProvider));
});

final occurrencesProvider = StreamProvider<List<TaskOccurrenceEntity>>((ref) {
  final pair = ref.watch(currentPairProvider);
  if (pair == null) return Stream.value([]);
  return ref
      .watch(taskOccurrenceRepositoryProvider)
      .watchOccurrencesByPairId(pair.id);
});

final pendingOccurrencesProvider = Provider<List<TaskOccurrenceEntity>>((ref) {
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences
      .where((o) =>
          o.status == AppConstants.pendingStatus ||
          o.status == AppConstants.inProgressStatus)
      .toList();
});

/// Pair-scoped: streams occurrences for a specific pair.
final occurrencesByPairIdProvider =
    StreamProvider.family<List<TaskOccurrenceEntity>, String>((ref, pairId) {
  // Guard: don't start Firestore streams until auth is confirmed
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref
      .watch(taskOccurrenceRepositoryProvider)
      .watchOccurrencesByPairId(pairId);
});
