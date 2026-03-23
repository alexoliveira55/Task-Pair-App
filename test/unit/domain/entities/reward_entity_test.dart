import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/reward_entity.dart';

void main() {
  final unlockedAt = DateTime(2024, 2, 1);

  RewardEntity createReward({
    String id = 'reward-1',
    String pairId = 'pair-1',
    String title = 'Movie Night',
    String? description = 'Watch a movie together',
    int requiredPoints = 50,
    bool isUnlocked = false,
    DateTime? unlockedAt_,
  }) {
    return RewardEntity(
      id: id,
      pairId: pairId,
      title: title,
      description: description,
      requiredPoints: requiredPoints,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt_,
    );
  }

  group('RewardEntity', () {
    test('should create with required fields only', () {
      final reward = RewardEntity(
        id: 'reward-1',
        pairId: 'pair-1',
        title: 'Movie Night',
        requiredPoints: 50,
        isUnlocked: false,
      );

      expect(reward.id, 'reward-1');
      expect(reward.pairId, 'pair-1');
      expect(reward.title, 'Movie Night');
      expect(reward.description, isNull);
      expect(reward.requiredPoints, 50);
      expect(reward.isUnlocked, false);
      expect(reward.unlockedAt, isNull);
    });

    test('should create with all fields', () {
      final reward = createReward(isUnlocked: true, unlockedAt_: unlockedAt);

      expect(reward.description, 'Watch a movie together');
      expect(reward.isUnlocked, true);
      expect(reward.unlockedAt, unlockedAt);
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final reward = createReward();
        final copy = reward.copyWith();

        expect(copy, equals(reward));
      });

      test('should copy with changed isUnlocked', () {
        final reward = createReward();
        final copy = reward.copyWith(isUnlocked: true);

        expect(copy.isUnlocked, true);
        expect(copy.id, reward.id);
      });

      test('should copy with changed title', () {
        final reward = createReward();
        final copy = reward.copyWith(title: 'Dinner Out');

        expect(copy.title, 'Dinner Out');
      });

      test('should copy with changed requiredPoints', () {
        final reward = createReward();
        final copy = reward.copyWith(requiredPoints: 100);

        expect(copy.requiredPoints, 100);
      });

      test('should copy with changed unlockedAt', () {
        final reward = createReward();
        final copy = reward.copyWith(unlockedAt: unlockedAt);

        expect(copy.unlockedAt, unlockedAt);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final reward1 = createReward();
        final reward2 = createReward();

        expect(reward1, equals(reward2));
      });

      test('should not be equal when id differs', () {
        final reward1 = createReward(id: 'reward-1');
        final reward2 = createReward(id: 'reward-2');

        expect(reward1, isNot(equals(reward2)));
      });

      test('should not be equal when isUnlocked differs', () {
        final reward1 = createReward(isUnlocked: false);
        final reward2 = createReward(isUnlocked: true);

        expect(reward1, isNot(equals(reward2)));
      });

      test('should have same hashCode for equal entities', () {
        final reward1 = createReward();
        final reward2 = createReward();

        expect(reward1.hashCode, equals(reward2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final reward = createReward(isUnlocked: true, unlockedAt_: unlockedAt);

      expect(reward.props, [
        'reward-1',
        'pair-1',
        'Movie Night',
        'Watch a movie together',
        50,
        true,
        unlockedAt,
      ]);
    });
  });
}
