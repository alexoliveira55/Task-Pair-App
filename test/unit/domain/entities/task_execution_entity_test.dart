import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/task_execution_entity.dart';

void main() {
  final executedAt = DateTime(2024, 1, 15, 10, 30);

  TaskExecutionEntity createExecution({
    String id = 'exec-1',
    String occurrenceId = 'occ-1',
    String taskId = 'task-1',
    String executedBy = 'user-1',
    DateTime? executedAt_,
    String? notes = 'Done',
    String? photoUrl,
  }) {
    return TaskExecutionEntity(
      id: id,
      occurrenceId: occurrenceId,
      taskId: taskId,
      executedBy: executedBy,
      executedAt: executedAt_ ?? executedAt,
      notes: notes,
      photoUrl: photoUrl,
    );
  }

  group('TaskExecutionEntity', () {
    test('should create with required fields only', () {
      final exec = TaskExecutionEntity(
        id: 'exec-1',
        occurrenceId: 'occ-1',
        taskId: 'task-1',
        executedBy: 'user-1',
        executedAt: executedAt,
      );

      expect(exec.id, 'exec-1');
      expect(exec.occurrenceId, 'occ-1');
      expect(exec.taskId, 'task-1');
      expect(exec.executedBy, 'user-1');
      expect(exec.executedAt, executedAt);
      expect(exec.notes, isNull);
      expect(exec.photoUrl, isNull);
    });

    test('should create with all fields', () {
      final exec = createExecution(photoUrl: 'https://example.com/photo.jpg');

      expect(exec.notes, 'Done');
      expect(exec.photoUrl, 'https://example.com/photo.jpg');
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final exec = createExecution();
        final copy = exec.copyWith();

        expect(copy, equals(exec));
      });

      test('should copy with changed notes', () {
        final exec = createExecution();
        final copy = exec.copyWith(notes: 'Updated notes');

        expect(copy.notes, 'Updated notes');
        expect(copy.id, exec.id);
      });

      test('should copy with changed photoUrl', () {
        final exec = createExecution();
        final copy = exec.copyWith(photoUrl: 'https://example.com/new.jpg');

        expect(copy.photoUrl, 'https://example.com/new.jpg');
      });

      test('should copy with changed executedBy', () {
        final exec = createExecution();
        final copy = exec.copyWith(executedBy: 'user-2');

        expect(copy.executedBy, 'user-2');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final exec1 = createExecution();
        final exec2 = createExecution();

        expect(exec1, equals(exec2));
      });

      test('should not be equal when id differs', () {
        final exec1 = createExecution(id: 'exec-1');
        final exec2 = createExecution(id: 'exec-2');

        expect(exec1, isNot(equals(exec2)));
      });

      test('should have same hashCode for equal entities', () {
        final exec1 = createExecution();
        final exec2 = createExecution();

        expect(exec1.hashCode, equals(exec2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final exec = createExecution();

      expect(exec.props, [
        'exec-1',
        'occ-1',
        'task-1',
        'user-1',
        executedAt,
        'Done',
        null,
      ]);
    });
  });
}
