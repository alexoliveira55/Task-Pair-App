import '../repositories/pair_repository.dart';

class DeletePairUseCase {
  final PairRepository _pairRepository;

  DeletePairUseCase(this._pairRepository);

  Future<void> execute({
    required String pairId,
  }) async {
    await _pairRepository.deletePair(pairId);
  }
}
