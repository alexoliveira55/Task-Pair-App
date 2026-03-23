import '../entities/pair_entity.dart';
import '../repositories/pair_repository.dart';
import '../repositories/user_repository.dart';

class GetUserPairsUseCase {
  final PairRepository _pairRepository;
  final UserRepository _userRepository;

  GetUserPairsUseCase(this._pairRepository, this._userRepository);

  Future<PairEntity?> execute(String userId) async {
    final user = await _userRepository.getUserById(userId);
    if (user == null || user.pairId == null) return null;

    return _pairRepository.getPairById(user.pairId!);
  }

  Stream<PairEntity?> watch(String pairId) {
    return _pairRepository.watchPair(pairId);
  }
}
