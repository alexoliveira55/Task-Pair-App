import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/utils/app_date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('formatDate', () {
      test('should format date as MMM dd, yyyy', () {
        final date = DateTime(2024, 1, 15);
        expect(AppDateUtils.formatDate(date), 'Jan 15, 2024');
      });

      test('should format December date correctly', () {
        final date = DateTime(2024, 12, 25);
        expect(AppDateUtils.formatDate(date), 'Dec 25, 2024');
      });
    });

    group('formatTime', () {
      test('should format time as hh:mm a', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        expect(AppDateUtils.formatTime(date), '02:30 PM');
      });

      test('should format morning time', () {
        final date = DateTime(2024, 1, 15, 9, 5);
        expect(AppDateUtils.formatTime(date), '09:05 AM');
      });
    });

    group('formatDateTime', () {
      test('should format date and time together', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        expect(AppDateUtils.formatDateTime(date), 'Jan 15, 2024 02:30 PM');
      });
    });

    group('formatShortDate', () {
      test('should format as MM/dd/yyyy', () {
        final date = DateTime(2024, 1, 15);
        expect(AppDateUtils.formatShortDate(date), '01/15/2024');
      });
    });

    group('formatRelative', () {
      test('should return minutes ago for recent times', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        expect(AppDateUtils.formatRelative(date), '5m ago');
      });

      test('should return hours ago for same day', () {
        final date = DateTime.now().subtract(const Duration(hours: 3));
        expect(AppDateUtils.formatRelative(date), '3h ago');
      });

      test('should return Yesterday for previous day', () {
        final date = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.formatRelative(date), 'Yesterday');
      });

      test('should return days ago for less than a week', () {
        final date = DateTime.now().subtract(const Duration(days: 4));
        expect(AppDateUtils.formatRelative(date), '4d ago');
      });

      test('should return formatted date for more than a week', () {
        final date = DateTime.now().subtract(const Duration(days: 10));
        final result = AppDateUtils.formatRelative(date);
        // Should be in MMM dd, yyyy format
        expect(result, isNotEmpty);
        expect(result.contains('ago'), isFalse);
      });
    });

    group('getWeekDays', () {
      test('should return 7 consecutive days', () {
        final monday = DateTime(2024, 1, 15); // A Monday
        final days = AppDateUtils.getWeekDays(monday);

        expect(days.length, 7);
        expect(days[0], DateTime(2024, 1, 15));
        expect(days[6], DateTime(2024, 1, 21));
      });

      test('each day should be exactly one day apart', () {
        final start = DateTime(2024, 1, 1);
        final days = AppDateUtils.getWeekDays(start);

        for (int i = 1; i < days.length; i++) {
          expect(
            days[i].difference(days[i - 1]).inDays,
            1,
          );
        }
      });
    });

    group('startOfWeek', () {
      test('should return Monday for a Wednesday', () {
        final wednesday = DateTime(2024, 1, 17); // Wednesday
        final monday = AppDateUtils.startOfWeek(wednesday);

        expect(monday.weekday, DateTime.monday);
        expect(monday, DateTime(2024, 1, 15));
      });

      test('should return same day for Monday', () {
        final monday = DateTime(2024, 1, 15); // Monday
        final result = AppDateUtils.startOfWeek(monday);

        expect(result, DateTime(2024, 1, 15));
      });

      test('should return Monday for Sunday', () {
        final sunday = DateTime(2024, 1, 21); // Sunday
        final monday = AppDateUtils.startOfWeek(sunday);

        expect(monday, DateTime(2024, 1, 15));
      });
    });

    group('startOfMonth', () {
      test('should return first day of month', () {
        final date = DateTime(2024, 3, 15);
        final start = AppDateUtils.startOfMonth(date);

        expect(start, DateTime(2024, 3, 1));
      });
    });

    group('endOfMonth', () {
      test('should return last day of month', () {
        final date = DateTime(2024, 1, 15);
        final end = AppDateUtils.endOfMonth(date);

        expect(end.day, 31);
        expect(end.month, 1);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
      });

      test('should handle February in leap year', () {
        final date = DateTime(2024, 2, 15);
        final end = AppDateUtils.endOfMonth(date);

        expect(end.day, 29); // 2024 is a leap year
      });

      test('should handle February in non-leap year', () {
        final date = DateTime(2023, 2, 15);
        final end = AppDateUtils.endOfMonth(date);

        expect(end.day, 28);
      });
    });
  });
}
