import 'package:intl/intl.dart';

class DateTimeHelper {
  const DateTimeHelper._(); // prevents instantiation

  /// Returns true if both dates fall on the same calendar day
  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  /// Formats a date as DD/MM/YYYY
  static String toDDMMYYYY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Returns the full month name (e.g. January, February)
  static String getMonthName(DateTime date) {
    return DateFormat.MMMM().format(date);
  }

  /// Creates a [DateTime] from a day–month ID (e.g. `"5-10"`) and a given year.
  ///
  /// The ID format must be `"day-month"`, where:
  /// - `day` is in the range 1–31
  /// - `month` is in the range 1–12
  static DateTime fromDayMonthId(
      String id,
      int year,
      ) {
    final parts = id.split('-');
    assert(parts.length == 2, 'Invalid day-month ID format: $id');

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return DateTime(year, month, day);
  }

  /// Creates a day–month ID string (e.g. `"5-10"`) from a [DateTime].
  ///
  /// The returned ID format is `"day-month"` (no zero-padding).
  static String toDayMonthId(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}';
  }


  /// Generates a unique key for the heatmap: "day-month-year"
  static String toHeatmapKey(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }
}
