import '../entities/pair_entity.dart';
import '../repositories/pair_repository.dart';
import '../repositories/user_repository.dart';

class CreatePairUseCase {
  final PairRepository _pairRepository;
  final UserRepository _userRepository;

  CreatePairUseCase(this._pairRepository, this._userRepository);

  Future<PairEntity> execute({
    required String user1Id,
    required String user2Id,
    required String name,
    int scoreTarget = 100,
  }) async {
    final pair = await _pairRepository.createPair(PairEntity(
      id: '',
      user1Id: user1Id,
      user2Id: user2Id,
      createdAt: DateTime.now(),
      name: name,
      scoreTarget: scoreTarget,
    ));

    await _userRepository.updatePairId(user1Id, pair.id);
    await _userRepository.updatePairId(user2Id, pair.id);

    return pair;
  }
}
