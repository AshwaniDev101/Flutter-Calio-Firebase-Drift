import 'package:flutter/widgets.dart';
import '../../../../core/app_settings.dart';
import '../../../../database/repository/food_stats_history_repository.dart';
import '../../../../models/food_stats.dart';

class CalorieFoodStatsHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieFoodStatsHistoryViewModel({required this.pageDateTime});


  final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;

  Map<String, FoodStats> monthStatsMap = {};
  double excessCalories = 0;

  Future<void> loadMonthStats() async {
    await _loadMonthStats();
  }

  Future<void> _loadMonthStats() async {
    monthStatsMap = await _repository.getMonthStats(
      year: pageDateTime.year,
      month: pageDateTime.month,
    );

    // final data = await FoodHistoryRepository.instance.getYearStats(year: pageDateTime.year);
    // final Map<int, FoodStats> flattened = {};
    //
    // data.forEach((month, days) {
    //   days.forEach((day, stats) {
    //     final combinedKey = month * 100 + day; // e.g., 305 → March 5
    //     flattened[combinedKey] = stats;
    //   });
    // });

    // monthStatsMap = flattened;

    excessCalories = _calculateNetExcess(monthStatsMap);

    notifyListeners();
  }

  double _calculateNetExcess(Map<String, FoodStats> monthStats) {
    double total = 0; // start from zero

    for (var food in monthStats.values) {
      total += food.calories - AppSettings.atMaxCalories;
      // print("Total ${total} => ${AppSettings.atMaxCalories} - ${food.calories} = ${food.calories - AppSettings.atMaxCalories}");
    }
    return total;
  }

  // Future<void> runTest() async {
  //   await FoodHistoryRepository.instance.changeConsumedCount(
  //     0,
  //     DietFood(
  //       id: '-1',
  //       name: 'Test 0',
  //       timestamp: Timestamp.fromDate(DateTime.now()),
  //       foodStats: FoodStats(proteins: 0, carbohydrates: 0, fats: 0, vitamins: 0, minerals: 0, calories: 1),
  //     ),
  //     DateTime(2025, 10, 25),
  //   );
  //   await loadMonthStats();
  // }

  void onDelete(DateTime cardDateTime) async {
    await _repository.deleteFoodStats(date: cardDateTime);
    // monthStatsMap.remove(cardDateTime.day.toString());
    monthStatsMap.remove('${cardDateTime.day.toString()}-${cardDateTime.month.toString()}');
    notifyListeners();
  }
}
