import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';

void main() {
  final updatedAt = DateTime(2024, 1, 15);

  ScoreEntity createScore({
    String id = 'score-1',
    String pairId = 'pair-1',
    String userId = 'user-1',
    int totalPoints = 50,
    int periodPoints = 20,
    DateTime? updatedAt_,
  }) {
    return ScoreEntity(
      id: id,
      pairId: pairId,
      userId: userId,
      totalPoints: totalPoints,
      periodPoints: periodPoints,
      updatedAt: updatedAt_ ?? updatedAt,
    );
  }

  group('ScoreEntity', () {
    test('should create with required fields', () {
      final score = createScore();

      expect(score.id, 'score-1');
      expect(score.pairId, 'pair-1');
      expect(score.userId, 'user-1');
      expect(score.totalPoints, 50);
      expect(score.periodPoints, 20);
      expect(score.updatedAt, updatedAt);
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final score = createScore();
        final copy = score.copyWith();

        expect(copy, equals(score));
      });

      test('should copy with changed totalPoints', () {
        final score = createScore();
        final copy = score.copyWith(totalPoints: 100);

        expect(copy.totalPoints, 100);
        expect(copy.id, score.id);
      });

      test('should copy with changed periodPoints', () {
        final score = createScore();
        final copy = score.copyWith(periodPoints: 30);

        expect(copy.periodPoints, 30);
      });

      test('should copy with changed userId', () {
        final score = createScore();
        final copy = score.copyWith(userId: 'user-2');

        expect(copy.userId, 'user-2');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final score1 = createScore();
        final score2 = createScore();

        expect(score1, equals(score2));
      });

      test('should not be equal when totalPoints differ', () {
        final score1 = createScore(totalPoints: 50);
        final score2 = createScore(totalPoints: 100);

        expect(score1, isNot(equals(score2)));
      });

      test('should not be equal when userId differs', () {
        final score1 = createScore(userId: 'user-1');
        final score2 = createScore(userId: 'user-2');

        expect(score1, isNot(equals(score2)));
      });

      test('should have same hashCode for equal entities', () {
        final score1 = createScore();
        final score2 = createScore();

        expect(score1.hashCode, equals(score2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final score = createScore();

      expect(score.props, [
        'score-1',
        'pair-1',
        'user-1',
        50,
        20,
        updatedAt,
      ]);
    });
  });
}
