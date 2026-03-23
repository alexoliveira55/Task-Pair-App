import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/domain/entities/task_validation_entity.dart';

void main() {
  final validatedAt = DateTime(2024, 1, 15, 14, 0);

  TaskValidationEntity createValidation({
    String id = 'val-1',
    String executionId = 'exec-1',
    String occurrenceId = 'occ-1',
    String validatedBy = 'user-2',
    DateTime? validatedAt_,
    bool isApproved = true,
    String? feedback,
  }) {
    return TaskValidationEntity(
      id: id,
      executionId: executionId,
      occurrenceId: occurrenceId,
      validatedBy: validatedBy,
      validatedAt: validatedAt_ ?? validatedAt,
      isApproved: isApproved,
      feedback: feedback,
    );
  }

  group('TaskValidationEntity', () {
    test('should create with required fields only', () {
      final val = TaskValidationEntity(
        id: 'val-1',
        executionId: 'exec-1',
        occurrenceId: 'occ-1',
        validatedBy: 'user-2',
        validatedAt: validatedAt,
        isApproved: true,
      );

      expect(val.id, 'val-1');
      expect(val.executionId, 'exec-1');
      expect(val.occurrenceId, 'occ-1');
      expect(val.validatedBy, 'user-2');
      expect(val.validatedAt, validatedAt);
      expect(val.isApproved, true);
      expect(val.feedback, isNull);
    });

    test('should create with feedback', () {
      final val = createValidation(feedback: 'Great job!');

      expect(val.feedback, 'Great job!');
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final val = createValidation();
        final copy = val.copyWith();

        expect(copy, equals(val));
      });

      test('should copy with changed isApproved', () {
        final val = createValidation(isApproved: true);
        final copy = val.copyWith(isApproved: false);

        expect(copy.isApproved, false);
        expect(copy.id, val.id);
      });

      test('should copy with changed feedback', () {
        final val = createValidation();
        final copy = val.copyWith(feedback: 'Needs improvement');

        expect(copy.feedback, 'Needs improvement');
      });

      test('should copy with changed validatedBy', () {
        final val = createValidation();
        final copy = val.copyWith(validatedBy: 'user-3');

        expect(copy.validatedBy, 'user-3');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final val1 = createValidation();
        final val2 = createValidation();

        expect(val1, equals(val2));
      });

      test('should not be equal when id differs', () {
        final val1 = createValidation(id: 'val-1');
        final val2 = createValidation(id: 'val-2');

        expect(val1, isNot(equals(val2)));
      });

      test('should not be equal when isApproved differs', () {
        final val1 = createValidation(isApproved: true);
        final val2 = createValidation(isApproved: false);

        expect(val1, isNot(equals(val2)));
      });

      test('should have same hashCode for equal entities', () {
        final val1 = createValidation();
        final val2 = createValidation();

        expect(val1.hashCode, equals(val2.hashCode));
      });
    });

    test('props should contain all fields', () {
      final val = createValidation(feedback: 'Good');

      expect(val.props, [
        'val-1',
        'exec-1',
        'occ-1',
        'user-2',
        validatedAt,
        true,
        'Good',
      ]);
    });
  });
}
