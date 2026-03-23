import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/task_entity.dart';
import 'package:task_pair_app/domain/entities/task_recurrence_entity.dart';
import 'package:task_pair_app/domain/usecases/get_task_details_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetTaskDetailsUseCase useCase;
  late MockTaskRepository mockTaskRepo;
  late MockTaskRecurrenceRepository mockRecurrenceRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockRecurrenceRepo = MockTaskRecurrenceRepository();
    useCase = GetTaskDetailsUseCase(mockTaskRepo, mockRecurrenceRepo);
  });

  group('GetTaskDetailsUseCase', () {
    test('should return task and recurrence when recurrenceId exists',
        () async {
      final task = TaskEntity(
        id: 'task-1',
        pairId: 'pair-1',
        title: 'Test Task',
        points: 10,
        isActive: true,
        recurrenceId: 'rec-1',
        createdAt: now,
        createdBy: 'user-1',
      );

      final recurrence = TaskRecurrenceEntity(
        id: 'rec-1',
        taskId: 'task-1',
        type: 'daily',
        startDate: now,
        isActive: true,
      );

      when(() => mockTaskRepo.getTaskById(any())).thenAnswer((_) async => task);
      when(() => mockRecurrenceRepo.getRecurrenceById(any()))
          .thenAnswer((_) async => recurrence);

      final result = await useCase.execute('task-1');

      expect(result.task, equals(task));
      expect(result.recurrence, equals(recurrence));
    });

    test('should return task without recurrence when recurrenceId is null',
        () async {
      final task = TaskEntity(
        id: 'task-1',
        pairId: 'pair-1',
        title: 'Test Task',
        points: 10,
        isActive: true,
        createdAt: now,
        createdBy: 'user-1',
      );

      when(() => mockTaskRepo.getTaskById(any())).thenAnswer((_) async => task);

      final result = await useCase.execute('task-1');

      expect(result.task, equals(task));
      expect(result.recurrence, isNull);
      verifyNever(() => mockRecurrenceRepo.getRecurrenceById(any()));
    });

    test('should throw when task is not found', () async {
      when(() => mockTaskRepo.getTaskById(any())).thenAnswer((_) async => null);

      expect(
        () => useCase.execute('nonexistent'),
        throwsException,
      );
    });
  });
}
