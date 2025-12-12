import 'food_stats.dart';

class FoodStatsEntry {
  final String id;
  final FoodStats stats;

  FoodStatsEntry(this.id, this.stats);

  DateTime getDateTime(int year) {
    final parts = id.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return DateTime(year, month, day);
  }
}
