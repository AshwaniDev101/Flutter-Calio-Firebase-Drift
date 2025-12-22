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

  /// Creates a DateTime from an ID like "5-10" (day-month) and a year
  static DateTime fromDayMonthId(
      String id,
      int year,
      ) {
    final parts = id.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return DateTime(year, month, day);
  }
}
