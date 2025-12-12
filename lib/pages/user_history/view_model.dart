import 'package:flutter/widgets.dart';
import '../../../core/app_settings.dart';
import '../../../database/repository/food_stats_history_repository.dart';
import '../../../models/food_stats_entry.dart';
import '../../models/food_stats.dart';
import '../../models/week_stats.dart';

class CalorieFoodStatsHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieFoodStatsHistoryViewModel({required this.pageDateTime});

  final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;

  List<FoodStatsEntry> yearStatsMap = [];
  List<WeekStats> weekListMap = [];

  double excessCalories = 0;

  Future<void> loadMonthStats() async {
    yearStatsMap = await _repository.getYearStats(year: pageDateTime.year);

    // excessCalories = _filterYearStatsMap(yearStatsMap);

    notifyListeners();
  }

  // This function is responsible for going though the whole list and filtering it. Extracting Data like Week List
  void _filterYearStatsMap(List<FoodStatsEntry> monthStats) {
    // double total = 0;

    int currentWeekNumber = -1;

    WeekStats weekStats = WeekStats(
      year: pageDateTime.year,
      foodStatsEntry: FoodStatsEntry('empty', FoodStats.empty()),
    );

    for (FoodStatsEntry entry in monthStats) {
      // Set access calories
      // excessCalories += entry.stats.calories - AppSettings.atMaxCalories;

      // WeekStats weekStats = WeekStats(year:pageDateTime.year, foodStatsEntry: entry);

      if (currentWeekNumber == WeekStats.getWeekInTheYear(pageDateTime)) {
        weekStats.foodStatsEntry.stats.sum(entry.stats);
      } else {
        if (weekStats.foodStatsEntry.id != 'empty') {
          weekListMap.add(weekStats);
        }

        currentWeekNumber = weekStats.weekNumber;
        weekStats = WeekStats(year: pageDateTime.year, foodStatsEntry: FoodStatsEntry('empty', FoodStats.empty()));
      }
    }
    // return total;
  }

  void onDelete(DateTime cardDateTime) async {
    await _repository.deleteFoodStats(date: cardDateTime);
    // monthStatsMap.remove(cardDateTime.day.toString());
    yearStatsMap.remove('${cardDateTime.day.toString()}-${cardDateTime.month.toString()}');
    notifyListeners();
  }

  String kcalToWeightString(double kcal) {
    const double kcalPerKg = 7700;

    double totalKg = kcal / kcalPerKg;

    int kg = totalKg.floor(); // whole kilograms
    int g = ((totalKg - kg) * 1000).round(); // remaining grams

    return "${kg}kg${g}g";
  }

  double sumFirstSevenCalories(vm) {
    List<FoodStatsEntry> items = vm.yearStatsMap;

    int limit = items.length < 7 ? items.length : 7;

    double total = 0;
    for (int i = 0; i < limit; i++) {
      var diff = items[i].stats.calories - 1700;
      total += diff;
    }

    return total;
  }
}
