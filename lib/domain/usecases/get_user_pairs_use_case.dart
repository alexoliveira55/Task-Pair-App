import '../entities/pair_entity.dart';
import '../repositories/pair_repository.dart';

class GetUserPairsUseCase {
  final PairRepository _pairRepository;

  GetUserPairsUseCase(this._pairRepository);

  /// Returns all pairs the user belongs to (as requester or executor).
  Future<List<PairEntity>> execute(String userId) async {
    final pairs = await _pairRepository.watchPairsByUserId(userId).first;
    return pairs;
  }

  Stream<PairEntity?> watch(String pairId) {
    return _pairRepository.watchPair(pairId);
  }
}
