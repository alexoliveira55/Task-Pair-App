import '../repositories/pair_repository.dart';
import '../repositories/user_repository.dart';

class DeletePairUseCase {
  final PairRepository _pairRepository;
  final UserRepository _userRepository;

  DeletePairUseCase(this._pairRepository, this._userRepository);

  Future<void> execute({
    required String pairId,
    required String user1Id,
    required String user2Id,
  }) async {
    await _userRepository.updatePairId(user1Id, null);
    await _userRepository.updatePairId(user2Id, null);
    await _pairRepository.deletePair(pairId);
  }
}
