import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  UserEntity createUser({
    String id = 'user-1',
    String email = 'test@example.com',
    String? displayName = 'Test User',
    String? photoUrl,
    DateTime? createdAt,
    String? pairId,
  }) {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt ?? now,
      pairId: pairId,
    );
  }

  group('UserEntity', () {
    test('should create with required fields', () {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        createdAt: now,
      );

      expect(user.id, 'user-1');
      expect(user.email, 'test@example.com');
      expect(user.createdAt, now);
      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
      expect(user.pairId, isNull);
    });

    test('should create with all fields', () {
      final user = createUser(
        photoUrl: 'https://example.com/photo.jpg',
        pairId: 'pair-1',
      );

      expect(user.id, 'user-1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.createdAt, now);
      expect(user.pairId, 'pair-1');
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final user = createUser();
        final copy = user.copyWith();

        expect(copy, equals(user));
      });

      test('should copy with changed id', () {
        final user = createUser();
        final copy = user.copyWith(id: 'user-2');

        expect(copy.id, 'user-2');
        expect(copy.email, user.email);
      });

      test('should copy with changed email', () {
        final user = createUser();
        final copy = user.copyWith(email: 'new@example.com');

        expect(copy.email, 'new@example.com');
      });

      test('should copy with changed displayName', () {
        final user = createUser();
        final copy = user.copyWith(displayName: 'New Name');

        expect(copy.displayName, 'New Name');
      });

      test('should copy with changed photoUrl', () {
        final user = createUser();
        final copy = user.copyWith(photoUrl: 'https://example.com/new.jpg');

        expect(copy.photoUrl, 'https://example.com/new.jpg');
      });

      test('should copy with changed pairId', () {
        final user = createUser();
        final copy = user.copyWith(pairId: 'pair-1');

        expect(copy.pairId, 'pair-1');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final user1 = createUser();
        final user2 = createUser();

        expect(user1, equals(user2));
      });

      test('should not be equal when id differs', () {
        final user1 = createUser(id: 'user-1');
        final user2 = createUser(id: 'user-2');

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when email differs', () {
        final user1 = createUser(email: 'a@example.com');
        final user2 = createUser(email: 'b@example.com');

        expect(user1, isNot(equals(user2)));
      });

      test('should have same hashCode for equal entities', () {
        final user1 = createUser();
        final user2 = createUser();

        expect(user1.hashCode, equals(user2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final user = createUser(pairId: 'pair-1');

      expect(user.props, [
        'user-1',
        'test@example.com',
        'Test User',
        null,
        now,
        'pair-1',
      ]);
    });
  });
}
