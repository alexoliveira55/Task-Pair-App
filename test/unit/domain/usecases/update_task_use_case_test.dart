import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/task_entity.dart';
import 'package:task_pair_app/domain/usecases/update_task_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late UpdateTaskUseCase useCase;
  late MockTaskRepository mockTaskRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    useCase = UpdateTaskUseCase(mockTaskRepo);
  });

  setUpAll(() {
    registerFallbackValue(TaskEntity(
      id: '',
      pairId: '',
      title: '',
      points: 0,
      isActive: false,
      createdAt: DateTime.now(),
      createdBy: '',
    ));
  });

  group('UpdateTaskUseCase', () {
    test('should delegate to repository updateTask', () async {
      final task = TaskEntity(
        id: 'task-1',
        pairId: 'pair-1',
        title: 'Updated Task',
        points: 20,
        isActive: true,
        createdAt: now,
        createdBy: 'user-1',
      );

      when(() => mockTaskRepo.updateTask(any())).thenAnswer((_) async {});

      await useCase.execute(task);

      verify(() => mockTaskRepo.updateTask(task)).called(1);
    });

    test('should propagate exception when updateTask fails', () async {
      final task = TaskEntity(
        id: 'task-1',
        pairId: 'pair-1',
        title: 'Task',
        points: 10,
        isActive: true,
        createdAt: now,
        createdBy: 'user-1',
      );

      when(() => mockTaskRepo.updateTask(any()))
          .thenThrow(Exception('Update failed'));

      expect(
        () => useCase.execute(task),
        throwsException,
      );
    });
  });
}
