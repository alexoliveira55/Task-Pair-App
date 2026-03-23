import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';
import 'package:task_pair_app/domain/usecases/get_pending_executions_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetPendingExecutionsUseCase useCase;
  late MockTaskOccurrenceRepository mockOccurrenceRepo;

  setUp(() {
    mockOccurrenceRepo = MockTaskOccurrenceRepository();
    useCase = GetPendingExecutionsUseCase(mockOccurrenceRepo);
  });

  group('GetPendingExecutionsUseCase', () {
    test('should return pending occurrences for pair', () async {
      final occurrences = [
        TaskOccurrenceEntity(
          id: 'occ-1',
          taskId: 'task-1',
          pairId: 'pair-1',
          dueDate: DateTime(2024, 1, 15),
          status: 'pending',
        ),
        TaskOccurrenceEntity(
          id: 'occ-2',
          taskId: 'task-2',
          pairId: 'pair-1',
          dueDate: DateTime(2024, 1, 16),
          status: 'pending',
        ),
      ];

      when(() => mockOccurrenceRepo.getPendingOccurrences(any()))
          .thenAnswer((_) async => occurrences);

      final result = await useCase.execute('pair-1');

      expect(result.length, 2);
      expect(result.first.status, 'pending');
      verify(() => mockOccurrenceRepo.getPendingOccurrences('pair-1'))
          .called(1);
    });

    test('should return empty list when no pending occurrences', () async {
      when(() => mockOccurrenceRepo.getPendingOccurrences(any()))
          .thenAnswer((_) async => []);

      final result = await useCase.execute('pair-1');

      expect(result, isEmpty);
    });
  });
}
