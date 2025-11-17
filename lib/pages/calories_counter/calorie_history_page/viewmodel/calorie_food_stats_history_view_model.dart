import 'package:flutter/widgets.dart';
import '../../../../core/app_settings.dart';
import '../../../../database/repository/food_stats_history_repository.dart';
import '../../../../models/food_stats.dart';
import '../../../../models/foodstats_entry.dart';

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
}
