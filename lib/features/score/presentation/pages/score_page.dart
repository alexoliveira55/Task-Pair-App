import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import '../../../../features/admin/presentation/providers/admin_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../features/dashboard/presentation/widgets/thermometer_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../domain/entities/pair_entity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScorePage extends ConsumerWidget {
  const ScorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairsAsExecutor = ref.watch(pairsAsExecutorProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.score)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thermometers only for pairs where I am the executor
            if (pairsAsExecutor.isEmpty)
              Center(child: Text(l10n.noPairs))
            else
              ...pairsAsExecutor.map((pair) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ExecutorThermometerCard(pair: pair),
                  )),
            // Admin section: all non-admin user thermometers
            if (isAdmin) ...[
              const SizedBox(height: 24),
              Text(l10n.allThermometers,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const _AdminThermometersView(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thermometer card for a pair where the current user is the executor.
class _ExecutorThermometerCard extends ConsumerWidget {
  final PairEntity pair;

  const _ExecutorThermometerCard({required this.pair});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myPoints = ref.watch(myPointsProvider);
    final thermometerProgress = ref.watch(thermometerProgressProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.myThermometer,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              pair.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ThermometerWidget(
              progress: thermometerProgress,
              currentPoints: myPoints,
              targetPoints: pair.scoreTarget,
              height: 180,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: thermometerProgress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(l10n
                .scoreProgress((thermometerProgress * 100).toStringAsFixed(1))),
          ],
        ),
      ),
    );
  }
}

/// Admin view showing thermometers for all non-admin users.
class _AdminThermometersView extends ConsumerWidget {
  const _AdminThermometersView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allScoresAsync = ref.watch(adminAllScoresProvider);
    final allUsersAsync = ref.watch(allUsersProvider);

    return allUsersAsync.when(
      data: (users) {
        return allScoresAsync.when(
          data: (scores) {
            final nonAdminUsers = users.where((u) => !u.isAdmin).toList();

            if (nonAdminUsers.isEmpty) {
              return Center(child: Text(l10n.noData));
            }

            final scoresByUser = <String, List<dynamic>>{};
            for (final score in scores) {
              scoresByUser.putIfAbsent(score.userId, () => []).add(score);
            }

            return Column(
              children: nonAdminUsers.map((user) {
                final userScores = scoresByUser[user.id] ?? [];
                final totalPoints = userScores.fold<int>(
                    0, (sum, s) => sum + (s.totalPoints as int));

                final displayName = user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : user.email;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.userThermometer(displayName),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _AdminUserThermometer(
                          userId: user.id,
                          totalPoints: totalPoints,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => AppErrorWidget(message: e.toString()),
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

/// Admin: thermometer for a specific user, showing all their executor pairs.
class _AdminUserThermometer extends ConsumerWidget {
  final String userId;
  final int totalPoints;

  const _AdminUserThermometer({
    required this.userId,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairRepo = ref.watch(pairRepositoryProvider);

    return FutureBuilder(
      future: _getExecutorPairs(pairRepo, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        final pairs = snapshot.data ?? [];
        if (pairs.isEmpty) {
          return Text(l10n.noPairYet);
        }
        return Column(
          children: pairs.map((pair) {
            final progress = (totalPoints / pair.scoreTarget).clamp(0.0, 1.0);
            return Column(
              children: [
                Text(pair.name, style: Theme.of(context).textTheme.bodySmall),
                ThermometerWidget(
                  progress: progress,
                  currentPoints: totalPoints,
                  targetPoints: pair.scoreTarget,
                  height: 120,
                ),
                const SizedBox(height: 4),
                Text(l10n.scoreProgress((progress * 100).toStringAsFixed(1))),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<PairEntity>> _getExecutorPairs(
      dynamic pairRepo, String userId) async {
    // Get pairs from the stream as a one-time snapshot
    return await pairRepo.watchPairsByUserId(userId).first.then(
        (List<PairEntity> pairs) =>
            pairs.where((p) => p.executorId == userId).toList());
  }
}
