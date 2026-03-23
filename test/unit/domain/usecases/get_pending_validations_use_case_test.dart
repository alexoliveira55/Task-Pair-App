import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/domain/usecases/get_pending_validations_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetPendingValidationsUseCase useCase;
  late MockTaskOccurrenceRepository mockOccurrenceRepo;

  setUp(() {
    mockOccurrenceRepo = MockTaskOccurrenceRepository();
    useCase = GetPendingValidationsUseCase(mockOccurrenceRepo);
  });

  group('GetPendingValidationsUseCase', () {
    test('should return occurrences with executed status', () async {
      final occurrences = [
        TaskOccurrenceEntity(
          id: 'occ-1',
          taskId: 'task-1',
          pairId: 'pair-1',
          dueDate: DateTime(2024, 1, 15),
          status: 'executed',
        ),
      ];

      when(() => mockOccurrenceRepo.getOccurrencesByStatus(any(), any()))
          .thenAnswer((_) async => occurrences);

      final result = await useCase.execute('pair-1');

      expect(result.length, 1);
      verify(() => mockOccurrenceRepo.getOccurrencesByStatus(
            'pair-1',
            'executed',
          )).called(1);
    });

    test('should return empty list when no pending validations', () async {
      when(() => mockOccurrenceRepo.getOccurrencesByStatus(any(), any()))
          .thenAnswer((_) async => []);

      final result = await useCase.execute('pair-1');

      expect(result, isEmpty);
    });
  });
}
