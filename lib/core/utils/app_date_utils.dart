import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date, [String? locale]) =>
      DateFormat.yMMMd(locale).format(date);

  static String formatTime(DateTime date, [String? locale]) =>
      DateFormat.jm(locale).format(date);

  static String formatDateTime(DateTime date, [String? locale]) =>
      DateFormat.yMMMd(locale).add_jm().format(date);

  static String formatShortDate(DateTime date, [String? locale]) =>
      DateFormat.yMd(locale).format(date);

  static String formatRelative(DateTime date, [String? locale]) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m';
      }
      return '${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return DateFormat.E(locale).format(date);
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }
    return formatDate(date, locale);
  }

  static List<DateTime> getWeekDays(DateTime weekStart) {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);
}
