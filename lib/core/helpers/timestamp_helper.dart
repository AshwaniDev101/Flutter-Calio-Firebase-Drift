class TimestampHelper {
  const TimestampHelper._(); // prevents instantiation

  /// Generates a readable, high-precision timestamp string.
  ///
  /// Example:
  /// `2025-10-18_09:42.123_456`
  ///
  /// Format:
  /// `YYYY-MM-DD_HH:MM.millisecond_microsecond`
  static String generateReadableTimestamp() {
    final now = DateTime.now();

    String two(int n) => n.toString().padLeft(2, '0');

    return '${now.year}-${two(now.month)}-${two(now.day)}_'
        '${two(now.hour)}:${two(now.minute)}.'
        '${now.millisecond}_${now.microsecond}';
  }
}
