import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/extensions/datetime_extension.dart';

void main() {
  group('DateTimeExtension', () {
    group('isToday', () {
      test('should return true for today', () {
        final today = DateTime.now();
        expect(today.isToday, isTrue);
      });

      test('should return false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, isFalse);
      });

      test('should return false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, isFalse);
      });
    });

    group('isYesterday', () {
      test('should return true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, isTrue);
      });

      test('should return false for today', () {
        final today = DateTime.now();
        expect(today.isYesterday, isFalse);
      });
    });

    group('isTomorrow', () {
      test('should return true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isTomorrow, isTrue);
      });

      test('should return false for today', () {
        final today = DateTime.now();
        expect(today.isTomorrow, isFalse);
      });
    });

    group('startOfDay', () {
      test('should return midnight of same day', () {
        final date = DateTime(2024, 3, 15, 14, 30, 45);
        final start = date.startOfDay;

        expect(start, DateTime(2024, 3, 15));
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
      });
    });

    group('endOfDay', () {
      test('should return 23:59:59 of same day', () {
        final date = DateTime(2024, 3, 15, 10, 0);
        final end = date.endOfDay;

        expect(end.year, 2024);
        expect(end.month, 3);
        expect(end.day, 15);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
      });
    });

    group('isSameDay', () {
      test('should return true for same day different times', () {
        final date1 = DateTime(2024, 3, 15, 10, 0);
        final date2 = DateTime(2024, 3, 15, 22, 30);

        expect(date1.isSameDay(date2), isTrue);
      });

      test('should return false for different days', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 16);

        expect(date1.isSameDay(date2), isFalse);
      });

      test('should return false for different months', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 4, 15);

        expect(date1.isSameDay(date2), isFalse);
      });
    });

    group('toFormattedString', () {
      test('should format as yyyy-MM-dd', () {
        final date = DateTime(2024, 3, 15);
        expect(date.toFormattedString(), '2024-03-15');
      });

      test('should pad single digit month and day', () {
        final date = DateTime(2024, 1, 5);
        expect(date.toFormattedString(), '2024-01-05');
      });
    });
  });
}
