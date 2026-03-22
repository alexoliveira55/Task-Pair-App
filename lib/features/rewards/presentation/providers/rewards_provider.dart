import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../features/score/presentation/providers/score_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../data/repositories/reward_repository_impl.dart';
import '../../../domain/entities/reward_entity.dart';
import '../use_cases/check_rewards_use_case.dart';

final rewardRepositoryProvider = Provider((ref) {
  return RewardRepositoryImpl(ref.watch(firestoreProvider));
});

final checkRewardsUseCaseProvider = Provider((ref) {
  return CheckRewardsUseCase(
    ref.watch(rewardRepositoryProvider),
    ref.watch(scoreRepositoryProvider),
  );
});

final rewardsProvider = StreamProvider<List<RewardEntity>>((ref) {
  final pairAsync = ref.watch(currentPairProvider);
  return pairAsync.when(
    data: (pair) {
      if (pair == null) return Stream.value([]);
      return ref.watch(rewardRepositoryProvider).watchRewardsByPairId(pair.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class RewardsNotifier extends StateNotifier<AsyncValue<void>> {
  final RewardRepositoryImpl _rewardRepository;
  final CheckRewardsUseCase _checkRewardsUseCase;
  final Ref _ref;

  RewardsNotifier(
      this._rewardRepository, this._checkRewardsUseCase, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createReward({
    required String title,
    String? description,
    required int requiredPoints,
  }) async {
    state = const AsyncValue.loading();
    try {
      final pair = _ref.read(currentPairProvider).value;
      if (pair == null) throw Exception('No pair found');

      await _rewardRepository.createReward(RewardEntity(
        id: '',
        pairId: pair.id,
        title: title,
        description: description,
        requiredPoints: requiredPoints,
        isUnlocked: false,
      ));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> checkAndUnlockRewards() async {
    final pair = _ref.read(currentPairProvider).value;
    if (pair == null) return;
    await _checkRewardsUseCase.execute(pair.id);
  }
}

final rewardsNotifierProvider =
    StateNotifierProvider<RewardsNotifier, AsyncValue<void>>((ref) {
  return RewardsNotifier(
    ref.watch(rewardRepositoryProvider),
    ref.watch(checkRewardsUseCaseProvider),
    ref,
  );
});
