import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ScorePage extends ConsumerWidget {
  const ScorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(scoresProvider);
    final pairAsync = ref.watch(currentPairProvider);
    final currentUserAsync = ref.watch(currentUserEntityProvider);
    final thermometerProgress = ref.watch(thermometerProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scores')),
      body: pairAsync.when(
        data: (pair) {
          if (pair == null) {
            return const Center(child: Text('No pair found'));
          }
          return scoresAsync.when(
            data: (scores) {
              final totalPoints = ref.read(totalPairPointsProvider);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              pair.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalPoints / ${pair.scoreTarget} points',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: thermometerProgress,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                '${(thermometerProgress * 100).toStringAsFixed(1)}% complete'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Individual Scores',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...scores.map((score) {
                      final isCurrentUser =
                          score.userId == currentUserAsync.value?.id;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrentUser
                                ? Colors.deepPurple
                                : Colors.grey,
                            child: Text(
                              '${score.totalPoints}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            isCurrentUser ? 'You' : 'Partner',
                            style: isCurrentUser
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null,
                          ),
                          subtitle: Text(
                              'Period: ${score.periodPoints} pts | Total: ${score.totalPoints} pts'),
                          trailing: isCurrentUser
                              ? const Chip(label: Text('You'))
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const LoadingWidget(),
            error: (e, _) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
