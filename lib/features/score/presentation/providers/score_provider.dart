import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/data/repositories/score_repository_impl.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';

final scoreRepositoryProvider = Provider((ref) {
  return ScoreRepositoryImpl(ref.watch(firestoreProvider));
});

final scoresProvider = StreamProvider<List<ScoreEntity>>((ref) {
  final pairAsync = ref.watch(currentPairProvider);
  return pairAsync.when(
    data: (pair) {
      if (pair == null) return Stream.value([]);
      return ref.watch(scoreRepositoryProvider).watchScoresByPairId(pair.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final totalPairPointsProvider = Provider<int>((ref) {
  final scores = ref.watch(scoresProvider).value ?? [];
  return scores.fold(0, (sum, s) => sum + s.totalPoints);
});

final thermometerProgressProvider = Provider<double>((ref) {
  final pair = ref.watch(currentPairProvider).value;
  if (pair == null) return 0.0;
  final totalPoints = ref.watch(totalPairPointsProvider);
  final progress = totalPoints / pair.scoreTarget;
  return progress.clamp(0.0, 1.0);
});
