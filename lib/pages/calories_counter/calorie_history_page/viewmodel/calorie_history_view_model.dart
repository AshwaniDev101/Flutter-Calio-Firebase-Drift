import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import '../../../../core/app_settings.dart';
import '../../../../database/repository/food_history_repository.dart';
import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';

class CalorieHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieHistoryViewModel({required this.pageDateTime});

  Map<String, FoodStats> monthStatsMap = {};
  double excessCalories = 0;

  Future<void> loadMonthStats() async {
    await _loadMonthStats();
  }

  Future<void> _loadMonthStats() async {
    monthStatsMap = await FoodHistoryRepository.instance.getMonthStats(
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

  Future<void> runTest() async {
    await FoodHistoryRepository.instance.changeConsumedCount(
      0,
      DietFood(
        id: '-1',
        name: 'Test 0',
        time: Timestamp.fromDate(DateTime.now()),
        foodStats: FoodStats(proteins: 0, carbohydrates: 0, fats: 0, vitamins: 0, minerals: 0, calories: 1),
      ),
      DateTime(2025, 10, 25),
    );
    await loadMonthStats();
  }

  void onDelete(DateTime cardDateTime) async {
    await FoodHistoryRepository.instance.deleteFoodStats(date: cardDateTime);
    // monthStatsMap.remove(cardDateTime.day.toString());
    monthStatsMap.remove('${cardDateTime.day.toString()}-${cardDateTime.month.toString()}');
    notifyListeners();
  }
}
