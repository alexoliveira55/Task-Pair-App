import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/task_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  TaskEntity createTask({
    String id = 'task-1',
    String pairId = 'pair-1',
    String title = 'Test Task',
    String? description = 'A test task',
    String? assignedTo = 'user-1',
    int points = 10,
    bool isActive = true,
    String? recurrenceId,
    DateTime? createdAt,
    String createdBy = 'user-1',
  }) {
    return TaskEntity(
      id: id,
      pairId: pairId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      points: points,
      isActive: isActive,
      recurrenceId: recurrenceId,
      createdAt: createdAt ?? now,
      createdBy: createdBy,
    );
  }

  group('TaskEntity', () {
    test('should create with required fields only', () {
      final task = TaskEntity(
        id: 'task-1',
        pairId: 'pair-1',
        title: 'Test Task',
        points: 10,
        isActive: true,
        createdAt: now,
        createdBy: 'user-1',
      );

      expect(task.id, 'task-1');
      expect(task.pairId, 'pair-1');
      expect(task.title, 'Test Task');
      expect(task.description, isNull);
      expect(task.assignedTo, isNull);
      expect(task.points, 10);
      expect(task.isActive, true);
      expect(task.recurrenceId, isNull);
      expect(task.createdAt, now);
      expect(task.createdBy, 'user-1');
    });

    test('should create with all fields', () {
      final task = createTask(recurrenceId: 'rec-1');

      expect(task.description, 'A test task');
      expect(task.assignedTo, 'user-1');
      expect(task.recurrenceId, 'rec-1');
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final task = createTask();
        final copy = task.copyWith();

        expect(copy, equals(task));
      });

      test('should copy with changed title', () {
        final task = createTask();
        final copy = task.copyWith(title: 'Updated Task');

        expect(copy.title, 'Updated Task');
        expect(copy.id, task.id);
      });

      test('should copy with changed points', () {
        final task = createTask();
        final copy = task.copyWith(points: 20);

        expect(copy.points, 20);
      });

      test('should copy with changed isActive', () {
        final task = createTask(isActive: true);
        final copy = task.copyWith(isActive: false);

        expect(copy.isActive, false);
      });

      test('should copy with changed assignedTo', () {
        final task = createTask();
        final copy = task.copyWith(assignedTo: 'user-2');

        expect(copy.assignedTo, 'user-2');
      });

      test('should copy with changed recurrenceId', () {
        final task = createTask();
        final copy = task.copyWith(recurrenceId: 'rec-1');

        expect(copy.recurrenceId, 'rec-1');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final task1 = createTask();
        final task2 = createTask();

        expect(task1, equals(task2));
      });

      test('should not be equal when id differs', () {
        final task1 = createTask(id: 'task-1');
        final task2 = createTask(id: 'task-2');

        expect(task1, isNot(equals(task2)));
      });

      test('should not be equal when title differs', () {
        final task1 = createTask(title: 'Task A');
        final task2 = createTask(title: 'Task B');

        expect(task1, isNot(equals(task2)));
      });

      test('should not be equal when points differ', () {
        final task1 = createTask(points: 10);
        final task2 = createTask(points: 20);

        expect(task1, isNot(equals(task2)));
      });

      test('should have same hashCode for equal entities', () {
        final task1 = createTask();
        final task2 = createTask();

        expect(task1.hashCode, equals(task2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final task = createTask(recurrenceId: 'rec-1');

      expect(task.props, [
        'task-1',
        'pair-1',
        'Test Task',
        'A test task',
        'user-1',
        10,
        true,
        'rec-1',
        null,
        null,
        now,
        'user-1',
      ]);
    });
  });
}
