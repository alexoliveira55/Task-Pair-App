import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/delete_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late DeletePairUseCase useCase;
  late MockPairRepository mockPairRepo;

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = DeletePairUseCase(mockPairRepo);
  });

  group('DeletePairUseCase', () {
    test('should delete pair', () async {
      when(() => mockPairRepo.deletePair(any())).thenAnswer((_) async {});

      await useCase.execute(pairId: 'pair-1');

      verify(() => mockPairRepo.deletePair('pair-1')).called(1);
    });

    test('should propagate exception when deletePair fails', () async {
      when(() => mockPairRepo.deletePair(any()))
          .thenThrow(Exception('Delete failed'));

      expect(
        () => useCase.execute(pairId: 'pair-1'),
        throwsException,
      );
    });
  });
}
