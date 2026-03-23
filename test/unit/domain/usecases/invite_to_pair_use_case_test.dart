import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';
import 'package:task_pair_app/domain/usecases/invite_to_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late InviteToPairUseCase useCase;
  late MockPairRepository mockPairRepo;

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = InviteToPairUseCase(mockPairRepo);
  });

  setUpAll(() {
    registerFallbackValue(PairInviteEntity(
      id: '',
      fromUserId: '',
      toEmail: '',
      pairId: '',
      status: '',
      createdAt: DateTime.now(),
    ));
  });

  group('InviteToPairUseCase', () {
    test('should create invite with pending status', () async {
      final createdInvite = PairInviteEntity(
        id: 'invite-1',
        fromUserId: 'user-1',
        toEmail: 'partner@example.com',
        pairId: 'pair-1',
        status: 'pending',
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockPairRepo.createInvite(any()))
          .thenAnswer((_) async => createdInvite);

      final result = await useCase.execute(
        fromUserId: 'user-1',
        toEmail: 'partner@example.com',
        pairId: 'pair-1',
      );

      expect(result.id, 'invite-1');
      expect(result.status, 'pending');

      final captured =
          verify(() => mockPairRepo.createInvite(captureAny())).captured;
      final invite = captured.first as PairInviteEntity;
      expect(invite.status, 'pending');
      expect(invite.fromUserId, 'user-1');
      expect(invite.toEmail, 'partner@example.com');
    });

    test('should propagate exception when createInvite fails', () async {
      when(() => mockPairRepo.createInvite(any()))
          .thenThrow(Exception('Failed'));

      expect(
        () => useCase.execute(
          fromUserId: 'user-1',
          toEmail: 'partner@example.com',
          pairId: 'pair-1',
        ),
        throwsException,
      );
    });
  });
}
