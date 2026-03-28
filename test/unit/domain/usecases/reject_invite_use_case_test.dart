import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/reject_invite_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late RejectInviteUseCase useCase;
  late MockPairRepository mockPairRepo;

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = RejectInviteUseCase(mockPairRepo);
  });

  group('RejectInviteUseCase', () {
    test('should update invite status to rejected', () async {
      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute('invite-1');

      verify(() => mockPairRepo.updateInviteStatus('invite-1', 'rejected'))
          .called(1);
    });

    test('should propagate exception when update fails', () async {
      when(() => mockPairRepo.updateInviteStatus(any(), any()))
          .thenThrow(Exception('Failed'));

      expect(
        () => useCase.execute('invite-1'),
        throwsException,
      );
    });
  });
}
