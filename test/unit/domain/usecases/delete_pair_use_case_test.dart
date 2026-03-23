import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/delete_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late DeletePairUseCase useCase;
  late MockPairRepository mockPairRepo;
  late MockUserRepository mockUserRepo;

  setUp(() {
    mockPairRepo = MockPairRepository();
    mockUserRepo = MockUserRepository();
    useCase = DeletePairUseCase(mockPairRepo, mockUserRepo);
  });

  group('DeletePairUseCase', () {
    test('should clear both users pairId and delete pair', () async {
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockPairRepo.deletePair(any())).thenAnswer((_) async {});

      await useCase.execute(
        pairId: 'pair-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
      );

      verify(() => mockUserRepo.updatePairId('user-1', null)).called(1);
      verify(() => mockUserRepo.updatePairId('user-2', null)).called(1);
      verify(() => mockPairRepo.deletePair('pair-1')).called(1);
    });

    test('should propagate exception when deletePair fails', () async {
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockPairRepo.deletePair(any()))
          .thenThrow(Exception('Delete failed'));

      expect(
        () => useCase.execute(
          pairId: 'pair-1',
          user1Id: 'user-1',
          user2Id: 'user-2',
        ),
        throwsException,
      );
    });
  });
}
