import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../../database/repository/food_stats_history_repository.dart';
import '../../../models/food_stats_entry.dart';
import '../../core/helpers/date_time_helper.dart';
import '../../models/food_stats.dart';
import '../../models/week_stats.dart';

class CalorieHistoryViewModel extends ChangeNotifier {
  final DateTime pageDateTime;
  final FoodStatsHistoryRepository _repository = FoodStatsHistoryRepository.instance;

  StreamSubscription<List<FoodStatsEntry>>? _subscription;
  bool _isDisposed = false;

  /// Raw daily stats for the year
  List<FoodStatsEntry> yearStatsList = [];

  /// Aggregated weekly stats
  List<WeekStats> weeklyStatsList = [];

  /// Heatmap data (day-level)
  Map<String, FoodStats> heatmap = {};

  CalorieHistoryViewModel({required this.pageDateTime}) {
    _listenToStats();
  }

  void _listenToStats() {
    _subscription?.cancel();
    _subscription = _repository.watchYearStats(year: pageDateTime.year).listen((allStatsList) {
      if (_isDisposed) return;

      yearStatsList = allStatsList;
      _buildDerivedStats(yearStatsList);
      notifyListeners();
    });
  }

  /// Builds weekly aggregates and heatmap from daily stats
  void _buildDerivedStats(List<FoodStatsEntry> allStatsList) {
    final Map<String, FoodStats> newHeatmap = {};
    final List<WeekStats> newWeeklyStatsList = [];

    if (allStatsList.isNotEmpty) {
      // Defensive: ensure stats are ordered by date
      final List<FoodStatsEntry> sortedList = List.from(allStatsList);
      sortedList.sort((a, b) {
        final dateA = DateTimeHelper.fromDayMonthId(a.id, pageDateTime.year);
        final dateB = DateTimeHelper.fromDayMonthId(b.id, pageDateTime.year);
        return dateA.compareTo(dateB);
      });

      int? currentWeekNumber;
      FoodStats weeklyTotal = FoodStats.empty();

      for (final entry in sortedList) {
        // Heatmap population
        newHeatmap['${entry.id}-${pageDateTime.year}'] = entry.foodStats;

        final dateTimeFromId = DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year);
        final entryWeek = WeekStats.getWeekInTheYear(dateTimeFromId);

        if (currentWeekNumber == entryWeek) {
          weeklyTotal = weeklyTotal.sum(entry.foodStats);
        } else {
          if (currentWeekNumber != null) {
            newWeeklyStatsList.add(WeekStats(
              weekNumber: currentWeekNumber,
              year: pageDateTime.year,
              foodStats: weeklyTotal,
            ));
          }

          currentWeekNumber = entryWeek;
          weeklyTotal = entry.foodStats;
        }
      }

      // Flush last week
      if (currentWeekNumber != null) {
        newWeeklyStatsList.add(WeekStats(
          weekNumber: currentWeekNumber,
          year: pageDateTime.year,
          foodStats: weeklyTotal,
        ));
      }
    }

    // Replace references so context.select detects the change
    heatmap = newHeatmap;
    weeklyStatsList = newWeeklyStatsList;
  }

  Future<void> onDelete(DateTime cardDateTime) async {
    await _repository.deleteFoodStats(date: cardDateTime);
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

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
