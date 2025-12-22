import 'package:calio/models/food_stats.dart';
import 'package:intl/intl.dart';

class WeekStats {
  final int weekNumber;
  final int year;
  final FoodStats foodStats;

  WeekStats({required this.weekNumber, required this.year, required this.foodStats});

  factory WeekStats.empty() {
    return WeekStats(weekNumber: 0, year: 0, foodStats: const FoodStats.empty());
  }

  bool isEqual(WeekStats other) {
    return other.weekNumber == weekNumber && other.year == year && other.foodStats == foodStats;
  }

  WeekStats copyWith({int? weekNumber, int? year, FoodStats? foodStats}) {
    return WeekStats(
      weekNumber: weekNumber ?? this.weekNumber,
      year: year ?? this.year,
      foodStats: foodStats ?? this.foodStats,
    );
  }

  static int getWeekInTheYear(DateTime dateTime) {
    // ISO week calculation
    final numberOfDaysInTheYear = int.parse(DateFormat("D").format(dateTime));
    return ((numberOfDaysInTheYear - dateTime.weekday + 10) ~/ 7); // Week ${weekInTheYear} example: Week 16
  }
}
