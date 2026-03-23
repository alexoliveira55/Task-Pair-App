import '../entities/reward_entity.dart';
import '../repositories/reward_repository.dart';

class CreateRewardUseCase {
  final RewardRepository _rewardRepository;

  CreateRewardUseCase(this._rewardRepository);

  Future<RewardEntity> execute({
    required String pairId,
    required String title,
    String? description,
    required int requiredPoints,
  }) async {
    return _rewardRepository.createReward(RewardEntity(
      id: '',
      pairId: pairId,
      title: title,
      description: description,
      requiredPoints: requiredPoints,
      isUnlocked: false,
    ));
  }
}
