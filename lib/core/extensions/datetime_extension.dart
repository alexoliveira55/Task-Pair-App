extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999, 999);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String toFormattedString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
