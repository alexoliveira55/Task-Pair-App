import '../entities/score_entity.dart';
import '../repositories/score_repository.dart';

class GetScoresByUserUseCase {
  final ScoreRepository _scoreRepository;

  GetScoresByUserUseCase(this._scoreRepository);

  Future<List<ScoreEntity>> execute(String userId) async {
    return _scoreRepository.getScoresByUserId(userId);
  }
}
