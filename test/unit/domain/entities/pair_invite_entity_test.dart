import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  PairInviteEntity createInvite({
    String id = 'invite-1',
    String fromUserId = 'user-1',
    String toEmail = 'partner@example.com',
    String pairId = 'pair-1',
    String status = 'pending',
    DateTime? createdAt,
  }) {
    return PairInviteEntity(
      id: id,
      fromUserId: fromUserId,
      toEmail: toEmail,
      pairId: pairId,
      status: status,
      createdAt: createdAt ?? now,
    );
  }

  group('PairInviteEntity', () {
    test('should create with required fields', () {
      final invite = createInvite();

      expect(invite.id, 'invite-1');
      expect(invite.fromUserId, 'user-1');
      expect(invite.toEmail, 'partner@example.com');
      expect(invite.pairId, 'pair-1');
      expect(invite.status, 'pending');
      expect(invite.createdAt, now);
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final invite = createInvite();
        final copy = invite.copyWith();

        expect(copy, equals(invite));
      });

      test('should copy with changed status', () {
        final invite = createInvite();
        final copy = invite.copyWith(status: 'accepted');

        expect(copy.status, 'accepted');
        expect(copy.id, invite.id);
      });

      test('should copy with changed toEmail', () {
        final invite = createInvite();
        final copy = invite.copyWith(toEmail: 'new@example.com');

        expect(copy.toEmail, 'new@example.com');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final invite1 = createInvite();
        final invite2 = createInvite();

        expect(invite1, equals(invite2));
      });

      test('should not be equal when id differs', () {
        final invite1 = createInvite(id: 'invite-1');
        final invite2 = createInvite(id: 'invite-2');

        expect(invite1, isNot(equals(invite2)));
      });

      test('should not be equal when status differs', () {
        final invite1 = createInvite(status: 'pending');
        final invite2 = createInvite(status: 'accepted');

        expect(invite1, isNot(equals(invite2)));
      });

      test('should have same hashCode for equal entities', () {
        final invite1 = createInvite();
        final invite2 = createInvite();

        expect(invite1.hashCode, equals(invite2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final invite = createInvite();

      expect(invite.props, [
        'invite-1',
        'user-1',
        'partner@example.com',
        'pair-1',
        'pending',
        now,
      ]);
    });
  });
}
