import 'food_stats.dart';

class FoodStatsEntry {
  final String id;
  final FoodStats foodStats;

  FoodStatsEntry(this.id, this.foodStats);

  DateTime getDateTime(int year) {

    print("ID:${id}");
    final parts = id.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return DateTime(year, month, day);
  }
}
