import '../entities/score_entity.dart';
import '../repositories/score_repository.dart';

class GetScoresByPairUseCase {
  final ScoreRepository _scoreRepository;

  GetScoresByPairUseCase(this._scoreRepository);

  Future<List<ScoreEntity>> execute(String pairId) async {
    return _scoreRepository.getScoresByPairId(pairId);
  }

  Stream<List<ScoreEntity>> watch(String pairId) {
    return _scoreRepository.watchScoresByPairId(pairId);
  }
}
