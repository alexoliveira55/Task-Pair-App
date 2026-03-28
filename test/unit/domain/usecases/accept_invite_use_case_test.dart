import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';
import 'package:task_pair_app/domain/usecases/accept_invite_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late AcceptInviteUseCase useCase;
  late MockPairRepository mockPairRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = AcceptInviteUseCase(mockPairRepo);
  });

  group('AcceptInviteUseCase', () {
    final invite = PairInviteEntity(
      id: 'invite-1',
      fromUserId: 'user-1',
      toEmail: 'partner@example.com',
      pairId: 'pair-1',
      status: 'pending',
      createdAt: now,
    );

    test('should accept invite and set executor on pair', () async {
      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockPairRepo.setExecutorId(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute(
        invite: invite,
        acceptingUserId: 'user-2',
      );

      verify(() => mockPairRepo.updateInviteStatus('invite-1', 'accepted'))
          .called(1);
      verify(() => mockPairRepo.setExecutorId('pair-1', 'user-2')).called(1);
    });

    test('should not set executor when pairId is empty', () async {
      final inviteNoPair = PairInviteEntity(
        id: 'invite-2',
        fromUserId: 'user-1',
        toEmail: 'partner@example.com',
        pairId: '',
        status: 'pending',
        createdAt: now,
      );

      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute(
        invite: inviteNoPair,
        acceptingUserId: 'user-2',
      );

      verify(() => mockPairRepo.updateInviteStatus('invite-2', 'accepted'))
          .called(1);
      verifyNever(() => mockPairRepo.setExecutorId(any(), any()));
    });
  });
}
