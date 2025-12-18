import 'package:flutter/widgets.dart';
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
  Map<String,FoodStats> heatmap = {};

  // double excessCalories = 0;

  Future<void> loadMonthStats() async {
    yearStatsMap = await _repository.getYearStats(year: pageDateTime.year);

    // excessCalories = _filterYearStatsMap(yearStatsMap);
    _filterYearStatsMap(yearStatsMap);

    notifyListeners();
  }

  // This function is responsible for going though the whole list and filtering it. Extracting Data like Week List
  void _filterYearStatsMap(List<FoodStatsEntry> allStatsList) {
    weekListMap.clear();

    int? currentWeekNumber;
    FoodStats foodStatsTotal = FoodStats.empty();

    String? lastEntryId;

    for (final entry in allStatsList) {

      heatmap['${entry.id}-${pageDateTime.year}'] = entry.foodStats;

      final entryWeek = WeekStats.getWeekInTheYear(entry.getDateTime(pageDateTime.year));

      // print('${currentWeekNumber} == ${entryWeek}');

      if (currentWeekNumber == entryWeek) {
        foodStatsTotal = foodStatsTotal.sum(entry.foodStats);

        // print('foodStats ${entry.foodStats.calories}');
        // print('foodStatsTotal == ${foodStatsTotal.calories}');
      } else {
        if (currentWeekNumber != null) {
          weekListMap.add(
            WeekStats(year: pageDateTime.year, foodStatsEntry: FoodStatsEntry(lastEntryId!, foodStatsTotal)),
          );
        }

        currentWeekNumber = entryWeek;
        foodStatsTotal = entry.foodStats;
      }
      lastEntryId = entry.id;
    }

    // add last week
    if (currentWeekNumber != null) {
      weekListMap.add(WeekStats(year: pageDateTime.year, foodStatsEntry: FoodStatsEntry(lastEntryId!, foodStatsTotal)));
    }

    // print('=========================');
    //
    // weekListMap.forEach((entry){
    //   print('${entry.weekNumber} ${entry.foodStatsEntry.foodStats.calories}');
    // });
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
      var diff = items[i].foodStats.calories - 1700;
      total += diff;
    }

    return total;
  }
}
