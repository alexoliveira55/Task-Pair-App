import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/delete_task_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late DeleteTaskUseCase useCase;
  late MockTaskRepository mockTaskRepo;
  late MockTaskRecurrenceRepository mockRecurrenceRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockRecurrenceRepo = MockTaskRecurrenceRepository();
    useCase = DeleteTaskUseCase(mockTaskRepo, mockRecurrenceRepo);
  });

  group('DeleteTaskUseCase', () {
    test('should delete task without recurrence', () async {
      when(() => mockTaskRepo.deleteTask(any())).thenAnswer((_) async {});

      await useCase.execute(taskId: 'task-1');

      verify(() => mockTaskRepo.deleteTask('task-1')).called(1);
      verifyNever(() => mockRecurrenceRepo.deactivateRecurrence(any()));
    });

    test(
        'should deactivate recurrence and delete task when recurrenceId provided',
        () async {
      when(() => mockRecurrenceRepo.deactivateRecurrence(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepo.deleteTask(any())).thenAnswer((_) async {});

      await useCase.execute(taskId: 'task-1', recurrenceId: 'rec-1');

      verify(() => mockRecurrenceRepo.deactivateRecurrence('rec-1')).called(1);
      verify(() => mockTaskRepo.deleteTask('task-1')).called(1);
    });

    test('should propagate exception when deleteTask fails', () async {
      when(() => mockTaskRepo.deleteTask(any()))
          .thenThrow(Exception('Delete failed'));

      expect(
        () => useCase.execute(taskId: 'task-1'),
        throwsException,
      );
    });
  });
}
