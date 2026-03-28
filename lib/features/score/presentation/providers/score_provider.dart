import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/data/repositories/score_repository_impl.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';
import 'package:task_pair_app/features/admin/presentation/providers/admin_provider.dart';

final scoreRepositoryProvider = Provider((ref) {
  return ScoreRepositoryImpl(ref.watch(firestoreProvider));
});

final scoresProvider = StreamProvider<List<ScoreEntity>>((ref) {
  final pair = ref.watch(currentPairProvider);
  if (pair == null) return Stream.value([]);
  return ref.watch(scoreRepositoryProvider).watchScoresByPairId(pair.id);
});

/// Current user's individual score within the pair.
final myScoreProvider = Provider<ScoreEntity?>((ref) {
  final scores = ref.watch(scoresProvider).value ?? [];
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return null;
  try {
    return scores.firstWhere((s) => s.userId == currentUser.id);
  } catch (_) {
    return null;
  }
});

/// Current user's individual points.
final myPointsProvider = Provider<int>((ref) {
  return ref.watch(myScoreProvider)?.totalPoints ?? 0;
});

final totalPairPointsProvider = Provider<int>((ref) {
  final scores = ref.watch(scoresProvider).value ?? [];
  return scores.fold(0, (sum, s) => sum + s.totalPoints);
});

/// Thermometer progress based on the current user's own points.
final thermometerProgressProvider = Provider<double>((ref) {
  final pair = ref.watch(currentPairProvider);
  if (pair == null) return 0.0;
  final myPoints = ref.watch(myPointsProvider);
  final progress = myPoints / pair.scoreTarget;
  return progress.clamp(0.0, 1.0);
});

// ── Pair-scoped family providers (for dashboard per-pair cards) ──

/// Scores for a specific pair.
final scoresByPairIdProvider =
    StreamProvider.family<List<ScoreEntity>, String>((ref, pairId) {
  // Guard: don't start Firestore streams until auth is confirmed
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(scoreRepositoryProvider).watchScoresByPairId(pairId);
});

/// Current user's points within a specific pair.
final myPointsByPairProvider = Provider.family<int, String>((ref, pairId) {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return 0;
  final scores = ref.watch(scoresByPairIdProvider(pairId)).value ?? [];
  try {
    return scores.firstWhere((s) => s.userId == currentUser.id).totalPoints;
  } catch (_) {
    return 0;
  }
});

/// Thermometer progress for a specific pair.
final thermometerProgressByPairProvider =
    Provider.family<double, ({String pairId, int scoreTarget})>((ref, args) {
  final myPoints = ref.watch(myPointsByPairProvider(args.pairId));
  if (args.scoreTarget <= 0) return 0.0;
  final progress = myPoints / args.scoreTarget;
  return progress.clamp(0.0, 1.0);
});

/// All scores across all pairs (admin only).
/// Fetches scores per non-admin user to stay within Firestore rule constraints.
final adminAllScoresProvider = FutureProvider<List<ScoreEntity>>((ref) async {
  final isAdmin = ref.watch(isAdminProvider);
  if (!isAdmin) return [];

  final allUsers = await ref.watch(userRepositoryProvider).getAllUsers();
  final nonAdminUsers = allUsers.where((u) => !u.isAdmin).toList();

  final repo = ref.watch(scoreRepositoryProvider);
  final allScores = <ScoreEntity>[];
  final seenIds = <String>{};

  for (final user in nonAdminUsers) {
    final scores = await repo.getScoresByUserId(user.id);
    for (final score in scores) {
      if (seenIds.add(score.id)) {
        allScores.add(score);
      }
    }
  }

  return allScores;
});
