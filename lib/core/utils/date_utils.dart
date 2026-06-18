import 'package:intl/intl.dart';

/// Date helpers used across the app. Habit completion is tracked by
/// calendar day, so everything keys off a normalized `yyyy-MM-dd` string.
class DateKeys {
  DateKeys._();

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  static String of(DateTime date) => _fmt.format(date);

  static String today() => of(DateTime.now());

  static DateTime stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Returns the last [days] dates (including today), oldest first.
  static List<DateTime> lastDays(int days) {
    final today = stripTime(DateTime.now());
    return List.generate(
      days,
      (i) => today.subtract(Duration(days: days - 1 - i)),
    );
  }
}

/// Streak math derived from a set of completed `yyyy-MM-dd` keys.
class StreakCalculator {
  /// Current consecutive-day streak ending today (or yesterday if today
  /// isn't done yet — the streak isn't broken until a full day is missed).
  static int current(Set<String> completedDates) {
    if (completedDates.isEmpty) return 0;
    var streak = 0;
    var cursor = DateKeys.stripTime(DateTime.now());

    // Allow today to be incomplete without breaking the streak.
    if (!completedDates.contains(DateKeys.of(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(DateKeys.of(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest streak ever recorded.
  static int longest(Set<String> completedDates) {
    if (completedDates.isEmpty) return 0;
    final dates = completedDates.map(DateTime.parse).toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        run++;
        best = run > best ? run : best;
      } else {
        run = 1;
      }
    }
    return best;
  }
}
