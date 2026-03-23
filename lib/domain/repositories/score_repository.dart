import '../entities/score_entity.dart';

abstract class ScoreRepository {
  Future<ScoreEntity?> getScoreByUserId(String userId, String pairId);
  Future<List<ScoreEntity>> getScoresByUserId(String userId);
  Future<List<ScoreEntity>> getScoresByPairId(String pairId);
  Future<void> upsertScore(ScoreEntity score);
  Future<void> addPoints(String userId, String pairId, int points);
  Stream<List<ScoreEntity>> watchScoresByPairId(String pairId);
}
