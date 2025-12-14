import 'package:calio/models/food_stats.dart';
import 'package:calio/models/food_stats_entry.dart';
import 'package:intl/intl.dart';

class WeekStats {
  late final int weekNumber;
  final int year;
  final FoodStatsEntry foodStatsEntry;

  WeekStats({required this.year, required this.foodStatsEntry}) {
    weekNumber = WeekStats.getWeekInTheYear(foodStatsEntry.getDateTime(year));
  }

  factory WeekStats.empty() {
    return WeekStats(year: 0, foodStatsEntry: FoodStatsEntry('1-1', const FoodStats.empty()));
  }

  bool isEqual(WeekStats weekStats) {
    if (weekStats.year == year && weekStats.foodStatsEntry.id == foodStatsEntry.id) {
      return true;
    }
    return false;
  }

  WeekStats copyWith({int? year, FoodStatsEntry? foodStatsEntry}) {
    return WeekStats(year: year ?? this.year, foodStatsEntry: foodStatsEntry ?? this.foodStatsEntry);
  }

  static int getWeekInTheYear(DateTime dateTime) {
    // ISO week calculation
    final numberOfDaysInTheYear = int.parse(DateFormat("D").format(dateTime));
    return ((numberOfDaysInTheYear - dateTime.weekday + 10) ~/ 7); // Week ${weekInTheYear} example: Week 16
  }
}
