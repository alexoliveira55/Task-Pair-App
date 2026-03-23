import '../entities/reward_entity.dart';

abstract class RewardRepository {
  Future<List<RewardEntity>> getRewardsByPairId(String pairId);
  Future<RewardEntity> createReward(RewardEntity reward);
  Future<void> updateReward(RewardEntity reward);
  Future<void> deleteReward(String id);
  Future<void> unlockReward(String rewardId, DateTime unlockedAt);
  Stream<List<RewardEntity>> watchRewardsByPairId(String pairId);
}
