import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/task_occurrence_entity.dart';

void main() {
  final dueDate = DateTime(2024, 1, 15);

  TaskOccurrenceEntity createOccurrence({
    String id = 'occ-1',
    String taskId = 'task-1',
    String pairId = 'pair-1',
    DateTime? dueDate_,
    String status = 'pending',
    String? assignedTo = 'user-1',
  }) {
    return TaskOccurrenceEntity(
      id: id,
      taskId: taskId,
      pairId: pairId,
      dueDate: dueDate_ ?? dueDate,
      status: status,
      assignedTo: assignedTo,
    );
  }

  group('TaskOccurrenceEntity', () {
    test('should create with required fields', () {
      final occ = TaskOccurrenceEntity(
        id: 'occ-1',
        taskId: 'task-1',
        pairId: 'pair-1',
        dueDate: dueDate,
        status: 'pending',
      );

      expect(occ.id, 'occ-1');
      expect(occ.taskId, 'task-1');
      expect(occ.pairId, 'pair-1');
      expect(occ.dueDate, dueDate);
      expect(occ.status, 'pending');
      expect(occ.assignedTo, isNull);
    });

    test('should create with all fields', () {
      final occ = createOccurrence();

      expect(occ.assignedTo, 'user-1');
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final occ = createOccurrence();
        final copy = occ.copyWith();

        expect(copy, equals(occ));
      });

      test('should copy with changed status', () {
        final occ = createOccurrence(status: 'pending');
        final copy = occ.copyWith(status: 'executed');

        expect(copy.status, 'executed');
        expect(copy.id, occ.id);
      });

      test('should copy with changed assignedTo', () {
        final occ = createOccurrence();
        final copy = occ.copyWith(assignedTo: 'user-2');

        expect(copy.assignedTo, 'user-2');
      });

      test('should copy with changed dueDate', () {
        final occ = createOccurrence();
        final newDate = DateTime(2024, 2, 1);
        final copy = occ.copyWith(dueDate: newDate);

        expect(copy.dueDate, newDate);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final occ1 = createOccurrence();
        final occ2 = createOccurrence();

        expect(occ1, equals(occ2));
      });

      test('should not be equal when id differs', () {
        final occ1 = createOccurrence(id: 'occ-1');
        final occ2 = createOccurrence(id: 'occ-2');

        expect(occ1, isNot(equals(occ2)));
      });

      test('should not be equal when status differs', () {
        final occ1 = createOccurrence(status: 'pending');
        final occ2 = createOccurrence(status: 'executed');

        expect(occ1, isNot(equals(occ2)));
      });

      test('should have same hashCode for equal entities', () {
        final occ1 = createOccurrence();
        final occ2 = createOccurrence();

        expect(occ1.hashCode, equals(occ2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final occ = createOccurrence();

      expect(occ.props, [
        'occ-1',
        'task-1',
        'pair-1',
        dueDate,
        null,
        null,
        'pending',
        'user-1',
        null,
      ]);
    });
  });
}
