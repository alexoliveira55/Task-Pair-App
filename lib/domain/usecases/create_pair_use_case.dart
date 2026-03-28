import '../entities/pair_entity.dart';
import '../repositories/pair_repository.dart';

class CreatePairUseCase {
  final PairRepository _pairRepository;

  CreatePairUseCase(this._pairRepository);

  Future<PairEntity> execute({
    required String requesterId,
    required String executorId,
    required String name,
    int scoreTarget = 100,
  }) async {
    final pair = await _pairRepository.createPair(PairEntity(
      id: '',
      requesterId: requesterId,
      executorId: executorId,
      createdAt: DateTime.now(),
      name: name,
      scoreTarget: scoreTarget,
    ));

    return pair;
  }
}
