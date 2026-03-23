import '../entities/reward_entity.dart';
import '../repositories/reward_repository.dart';

class GetRewardsByPairUseCase {
  final RewardRepository _rewardRepository;

  GetRewardsByPairUseCase(this._rewardRepository);

  Future<List<RewardEntity>> execute(String pairId) async {
    return _rewardRepository.getRewardsByPairId(pairId);
  }

  Stream<List<RewardEntity>> watch(String pairId) {
    return _rewardRepository.watchRewardsByPairId(pairId);
  }
}
