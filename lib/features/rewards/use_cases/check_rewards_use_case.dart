import '../../../domain/entities/reward_entity.dart';
import '../../../domain/repositories/reward_repository.dart';
import '../../../domain/repositories/score_repository.dart';

class CheckRewardsUseCase {
  final RewardRepository _rewardRepository;
  final ScoreRepository _scoreRepository;

  CheckRewardsUseCase(this._rewardRepository, this._scoreRepository);

  Future<List<RewardEntity>> execute(String pairId) async {
    final scores = await _scoreRepository.getScoresByPairId(pairId);
    final totalPoints = scores.fold(0, (sum, s) => sum + s.totalPoints);
    final rewards = await _rewardRepository.getRewardsByPairId(pairId);

    final unlocked = <RewardEntity>[];
    for (final reward in rewards) {
      if (!reward.isUnlocked && totalPoints >= reward.requiredPoints) {
        await _rewardRepository.unlockReward(reward.id, DateTime.now());
        unlocked.add(reward.copyWith(isUnlocked: true, unlockedAt: DateTime.now()));
      }
    }
    return unlocked;
  }
}
