import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';
import 'package:task_pair_app/domain/usecases/accept_invite_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late AcceptInviteUseCase useCase;
  late MockPairRepository mockPairRepo;
  late MockUserRepository mockUserRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    mockUserRepo = MockUserRepository();
    useCase = AcceptInviteUseCase(mockPairRepo, mockUserRepo);
  });

  setUpAll(() {
    registerFallbackValue(PairEntity(
      id: '',
      user1Id: '',
      user2Id: '',
      createdAt: DateTime.now(),
      name: '',
      scoreTarget: 0,
    ));
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

    final pair = PairEntity(
      id: 'pair-1',
      user1Id: 'user-1',
      user2Id: '',
      createdAt: now,
      name: 'Test Pair',
      scoreTarget: 100,
    );

    test('should accept invite, update pair, and update user pairId', () async {
      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockPairRepo.getPairById(any())).thenAnswer((_) async => pair);
      when(() => mockPairRepo.updatePair(any())).thenAnswer((_) async {});
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute(
        invite: invite,
        acceptingUserId: 'user-2',
      );

      verify(() => mockPairRepo.updateInviteStatus('invite-1', 'accepted'))
          .called(1);
      verify(() => mockPairRepo.getPairById('pair-1')).called(1);

      final captured =
          verify(() => mockPairRepo.updatePair(captureAny())).captured;
      final updatedPair = captured.first as PairEntity;
      expect(updatedPair.user2Id, 'user-2');

      verify(() => mockUserRepo.updatePairId('user-2', 'pair-1')).called(1);
    });

    test('should throw when pair is not found', () async {
      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockPairRepo.getPairById(any())).thenAnswer((_) async => null);

      expect(
        () => useCase.execute(
          invite: invite,
          acceptingUserId: 'user-2',
        ),
        throwsException,
      );
    });
  });
}
