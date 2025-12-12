import 'package:flutter/widgets.dart';
import '../../../core/app_settings.dart';
import '../../../database/repository/food_stats_history_repository.dart';
import '../../../models/food_stats_entry.dart';

class CalorieFoodStatsHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieFoodStatsHistoryViewModel({required this.pageDateTime});

  final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;

  List<FoodStatsEntry> monthStatsMap = [];
  double excessCalories = 0;

  Future<void> loadMonthStats() async {
    await _loadMonthStats();
  }

  Future<void> _loadMonthStats() async {
    monthStatsMap = await _repository.getMonthStats(year: pageDateTime.year, month: pageDateTime.month);

    excessCalories = _calculateNetExcess(monthStatsMap);

    notifyListeners();
  }

  double _calculateNetExcess(List<FoodStatsEntry> monthStats) {
    double total = 0;

    for (var entry in monthStats) {
      total += entry.stats.calories - AppSettings.atMaxCalories;
    }

    return total;
  }

  void onDelete(DateTime cardDateTime) async {
    await _repository.deleteFoodStats(date: cardDateTime);
    // monthStatsMap.remove(cardDateTime.day.toString());
    monthStatsMap.remove('${cardDateTime.day.toString()}-${cardDateTime.month.toString()}');
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
    List<FoodStatsEntry> items = vm.monthStatsMap;

    int limit = items.length < 7 ? items.length : 7;

    double total = 0;
    for (int i = 0; i < limit; i++) {
      var diff = items[i].stats.calories - 1700;
      total += diff;
    }

    return total;
  }
}
