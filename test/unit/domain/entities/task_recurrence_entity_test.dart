import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/task_recurrence_entity.dart';

void main() {
  final startDate = DateTime(2024, 1, 1);
  final endDate = DateTime(2024, 12, 31);

  TaskRecurrenceEntity createRecurrence({
    String id = 'rec-1',
    String taskId = 'task-1',
    String type = 'daily',
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? startDate_,
    DateTime? endDate_,
    bool isActive = true,
  }) {
    return TaskRecurrenceEntity(
      id: id,
      taskId: taskId,
      type: type,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      startDate: startDate_ ?? startDate,
      endDate: endDate_,
      isActive: isActive,
    );
  }

  group('TaskRecurrenceEntity', () {
    test('should create with required fields only', () {
      final rec = TaskRecurrenceEntity(
        id: 'rec-1',
        taskId: 'task-1',
        type: 'daily',
        startDate: startDate,
        isActive: true,
      );

      expect(rec.id, 'rec-1');
      expect(rec.taskId, 'task-1');
      expect(rec.type, 'daily');
      expect(rec.daysOfWeek, isNull);
      expect(rec.dayOfMonth, isNull);
      expect(rec.startDate, startDate);
      expect(rec.endDate, isNull);
      expect(rec.isActive, true);
    });

    test('should create weekly recurrence with daysOfWeek', () {
      final rec = createRecurrence(
        type: 'weekly',
        daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
      );

      expect(rec.type, 'weekly');
      expect(rec.daysOfWeek, [1, 3, 5]);
    });

    test('should create monthly recurrence with dayOfMonth', () {
      final rec = createRecurrence(
        type: 'monthly',
        dayOfMonth: 15,
      );

      expect(rec.type, 'monthly');
      expect(rec.dayOfMonth, 15);
    });

    test('should create with endDate', () {
      final rec = createRecurrence(endDate_: endDate);

      expect(rec.endDate, endDate);
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final rec = createRecurrence();
        final copy = rec.copyWith();

        expect(copy, equals(rec));
      });

      test('should copy with changed type', () {
        final rec = createRecurrence(type: 'daily');
        final copy = rec.copyWith(type: 'weekly');

        expect(copy.type, 'weekly');
        expect(copy.id, rec.id);
      });

      test('should copy with changed isActive', () {
        final rec = createRecurrence(isActive: true);
        final copy = rec.copyWith(isActive: false);

        expect(copy.isActive, false);
      });

      test('should copy with changed daysOfWeek', () {
        final rec = createRecurrence();
        final copy = rec.copyWith(daysOfWeek: [2, 4]);

        expect(copy.daysOfWeek, [2, 4]);
      });

      test('should copy with changed dayOfMonth', () {
        final rec = createRecurrence();
        final copy = rec.copyWith(dayOfMonth: 20);

        expect(copy.dayOfMonth, 20);
      });

      test('should copy with changed endDate', () {
        final rec = createRecurrence();
        final copy = rec.copyWith(endDate: endDate);

        expect(copy.endDate, endDate);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final rec1 = createRecurrence();
        final rec2 = createRecurrence();

        expect(rec1, equals(rec2));
      });

      test('should not be equal when type differs', () {
        final rec1 = createRecurrence(type: 'daily');
        final rec2 = createRecurrence(type: 'weekly');

        expect(rec1, isNot(equals(rec2)));
      });

      test('should not be equal when isActive differs', () {
        final rec1 = createRecurrence(isActive: true);
        final rec2 = createRecurrence(isActive: false);

        expect(rec1, isNot(equals(rec2)));
      });

      test('should be equal when daysOfWeek match', () {
        final rec1 = createRecurrence(daysOfWeek: [1, 2, 3]);
        final rec2 = createRecurrence(daysOfWeek: [1, 2, 3]);

        expect(rec1, equals(rec2));
      });

      test('should have same hashCode for equal entities', () {
        final rec1 = createRecurrence();
        final rec2 = createRecurrence();

        expect(rec1.hashCode, equals(rec2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final rec = createRecurrence(
        daysOfWeek: [1, 3],
        dayOfMonth: 10,
        endDate_: endDate,
      );

      expect(rec.props, [
        'rec-1',
        'task-1',
        'daily',
        [1, 3],
        10,
        null,
        startDate,
        endDate,
        true,
      ]);
    });
  });
}
