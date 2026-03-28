import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  PairEntity createPair({
    String id = 'pair-1',
    String requesterId = 'user-1',
    String executorId = 'user-2',
    DateTime? createdAt,
    String name = 'Test Pair',
    int scoreTarget = 100,
  }) {
    return PairEntity(
      id: id,
      requesterId: requesterId,
      executorId: executorId,
      createdAt: createdAt ?? now,
      name: name,
      scoreTarget: scoreTarget,
    );
  }

  group('PairEntity', () {
    test('should create with required fields', () {
      final pair = createPair();

      expect(pair.id, 'pair-1');
      expect(pair.requesterId, 'user-1');
      expect(pair.executorId, 'user-2');
      expect(pair.createdAt, now);
      expect(pair.name, 'Test Pair');
      expect(pair.scoreTarget, 100);
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final pair = createPair();
        final copy = pair.copyWith();

        expect(copy, equals(pair));
      });

      test('should copy with changed name', () {
        final pair = createPair();
        final copy = pair.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
        expect(copy.id, pair.id);
      });

      test('should copy with changed scoreTarget', () {
        final pair = createPair();
        final copy = pair.copyWith(scoreTarget: 200);

        expect(copy.scoreTarget, 200);
      });

      test('should copy with changed executorId', () {
        final pair = createPair();
        final copy = pair.copyWith(executorId: 'user-3');

        expect(copy.executorId, 'user-3');
        expect(copy.requesterId, 'user-1');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final pair1 = createPair();
        final pair2 = createPair();

        expect(pair1, equals(pair2));
      });

      test('should not be equal when id differs', () {
        final pair1 = createPair(id: 'pair-1');
        final pair2 = createPair(id: 'pair-2');

        expect(pair1, isNot(equals(pair2)));
      });

      test('should not be equal when scoreTarget differs', () {
        final pair1 = createPair(scoreTarget: 100);
        final pair2 = createPair(scoreTarget: 200);

        expect(pair1, isNot(equals(pair2)));
      });

      test('should have same hashCode for equal entities', () {
        final pair1 = createPair();
        final pair2 = createPair();

        expect(pair1.hashCode, equals(pair2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final pair = createPair();

      expect(pair.props, [
        'pair-1',
        'user-1',
        'user-2',
        now,
        'Test Pair',
        100,
      ]);
    });
  });
}
