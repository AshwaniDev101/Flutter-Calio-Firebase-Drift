import 'package:flutter/widgets.dart';

import '../../../database/repository/food_stats_history_repository.dart';
import '../../../models/food_stats_entry.dart';
import '../../core/helpers/date_time_helper.dart';
import '../../models/food_stats.dart';
import '../../models/week_stats.dart';

class CalorieHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieHistoryViewModel({required this.pageDateTime});

  final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;

  /// Raw daily stats for the year
  List<FoodStatsEntry> yearStatsList = [];

  /// Aggregated weekly stats
  List<WeekStats> weeklyStatsList = [];

  /// Heatmap data (day-level)
  Map<String, FoodStats> heatmap = {};

  Future<void> loadMonthStats() async {
    yearStatsList = await _repository.getYearStats(year: pageDateTime.year);

    _buildDerivedStats(yearStatsList);

    notifyListeners();
  }

  /// Builds weekly aggregates and heatmap from daily stats
  void _buildDerivedStats(List<FoodStatsEntry> allStatsList) {
    weeklyStatsList.clear();
    heatmap.clear();

    if (allStatsList.isEmpty) return;

    // Defensive: ensure stats are ordered by date
    // allStatsList.sort((a, b) => a.getDateTime(pageDateTime.year).compareTo(b.getDateTime(pageDateTime.year)));
    // allStatsList.sort((a, b) {
    //   final dateA = DateTimeHelper.fromDayMonthId(a.id, pageDateTime.year);
    //   final dateB = DateTimeHelper.fromDayMonthId(b.id, pageDateTime.year);
    //   return dateA.compareTo(dateB);
    // });

    int? currentWeekNumber;
    FoodStats weeklyTotal = FoodStats.empty();

    for (final entry in allStatsList) {
      // Heatmap population
      heatmap['${entry.id}-${pageDateTime.year}'] = entry.foodStats;

      final dateTimeFromId = DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year);

      final entryWeek = WeekStats.getWeekInTheYear(dateTimeFromId);

      if (currentWeekNumber == entryWeek) {
        weeklyTotal = weeklyTotal.sum(entry.foodStats);
      } else {
        if (currentWeekNumber != null) {
          _addWeeklyStats(currentWeekNumber, weeklyTotal);
        }

        currentWeekNumber = entryWeek;
        weeklyTotal = entry.foodStats;
      }
    }

    // Flush last week
    if (currentWeekNumber != null) {
      _addWeeklyStats(currentWeekNumber, weeklyTotal);
    }
  }

  void _addWeeklyStats(int weekNumber, FoodStats total) {
    weeklyStatsList.add(WeekStats(weekNumber: weekNumber, year: pageDateTime.year, foodStats: total));
  }

  Future<void> onDelete(DateTime cardDateTime) async {
    await _repository.deleteFoodStats(date: cardDateTime);

    yearStatsList.removeWhere(
      (entry) =>
          DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year).year == cardDateTime.year &&
          DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year).month == cardDateTime.month &&
          DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year).day == cardDateTime.day,
    );

    _buildDerivedStats(yearStatsList);

    notifyListeners();
  }

  String kcalToWeightString(double kcal) {
    const double kcalPerKg = 7700;

    final double totalKg = kcal / kcalPerKg;
    final int kg = totalKg.floor();
    final int g = ((totalKg - kg) * 1000).round();

    return '${kg}kg${g}g';
  }

  double sumFirstSevenCalories() {
    final int limit = yearStatsList.length < 7 ? yearStatsList.length : 7;

    double total = 0;
    for (int i = 0; i < limit; i++) {
      total += yearStatsList[i].foodStats.calories - 1700;
    }

    return total;
  }
}

// import 'package:flutter/widgets.dart';
// import '../../../database/repository/food_stats_history_repository.dart';
// import '../../../models/food_stats_entry.dart';
// import '../../models/food_stats.dart';
// import '../../models/week_stats.dart';
//
// class CalorieHistoryViewModel extends ChangeNotifier {
//   final DateTime pageDateTime;
//
//   CalorieHistoryViewModel({required this.pageDateTime});
//
//   final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;
//
//   List<FoodStatsEntry> yearStatsMap = [];
//   List<WeekStats> weekListMap = [];
//   Map<String, FoodStats> heatmap = {};
//
//   // double excessCalories = 0;
//
//   Future<void> loadMonthStats() async {
//     yearStatsMap = await _repository.getYearStats(year: pageDateTime.year);
//
//     // excessCalories = _filterYearStatsMap(yearStatsMap);
//     _filterYearStatsMap(yearStatsMap);
//
//     notifyListeners();
//   }
//
//   // This function is responsible for going though the whole list and filtering it. Extracting Data like Week List
//   void _filterYearStatsMap(List<FoodStatsEntry> allStatsList) {
//     weekListMap.clear();
//
//     int? currentWeekNumber;
//     FoodStats foodStatsTotal = FoodStats.empty();
//
//     for (final entry in allStatsList) {
//       heatmap['${entry.id}-${pageDateTime.year}'] = entry.foodStats;
//
//       final entryWeek = WeekStats.getWeekInTheYear(entry.getDateTime(pageDateTime.year));
//
//       if (currentWeekNumber == entryWeek) {
//         foodStatsTotal = foodStatsTotal.sum(entry.foodStats);
//       } else {
//         if (currentWeekNumber != null) {
//           weekListMap.add(
//             WeekStats(
//               weekNumber: currentWeekNumber,
//               year: pageDateTime.year,
//               foodStats: foodStatsTotal,
//             ),
//           );
//         }
//
//         currentWeekNumber = entryWeek;
//         foodStatsTotal = entry.foodStats;
//       }
//     }
//
//     // add last week
//     if (currentWeekNumber != null) {
//       weekListMap.add(
//         WeekStats(
//           weekNumber: currentWeekNumber,
//           year: pageDateTime.year,
//           foodStats: foodStatsTotal,
//         ),
//       );
//     }
//   }
//
//   void onDelete(DateTime cardDateTime) async {
//     await _repository.deleteFoodStats(date: cardDateTime);
//     // monthStatsMap.remove(cardDateTime.day.toString());
//     yearStatsMap.remove('${cardDateTime.day.toString()}-${cardDateTime.month.toString()}');
//     notifyListeners();
//   }
//
//   String kcalToWeightString(double kcal) {
//     const double kcalPerKg = 7700;
//
//     double totalKg = kcal / kcalPerKg;
//
//     int kg = totalKg.floor(); // whole kilograms
//     int g = ((totalKg - kg) * 1000).round(); // remaining grams
//
//     return "${kg}kg${g}g";
//   }
//
//   double sumFirstSevenCalories(vm) {
//     List<FoodStatsEntry> items = vm.yearStatsMap;
//
//     int limit = items.length < 7 ? items.length : 7;
//
//     double total = 0;
//     for (int i = 0; i < limit; i++) {
//       var diff = items[i].foodStats.calories - 1700;
//       total += diff;
//     }
//
//     return total;
//   }
// }
