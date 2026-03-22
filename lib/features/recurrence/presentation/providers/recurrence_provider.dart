import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../data/repositories/task_occurrence_repository_impl.dart';
import '../../../domain/entities/task_occurrence_entity.dart';

final taskOccurrenceRepositoryProvider = Provider((ref) {
  return TaskOccurrenceRepositoryImpl(ref.watch(firestoreProvider));
});

final occurrencesProvider = StreamProvider<List<TaskOccurrenceEntity>>((ref) {
  final pairAsync = ref.watch(currentPairProvider);
  return pairAsync.when(
    data: (pair) {
      if (pair == null) return Stream.value([]);
      return ref
          .watch(taskOccurrenceRepositoryProvider)
          .watchOccurrencesByPairId(pair.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final pendingOccurrencesProvider =
    Provider<List<TaskOccurrenceEntity>>((ref) {
  final occurrences = ref.watch(occurrencesProvider).value ?? [];
  return occurrences.where((o) => o.status == 'pending').toList();
});
