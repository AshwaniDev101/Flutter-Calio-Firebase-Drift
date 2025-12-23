import '../../models/food_stats.dart';
import '../../models/food_stats_entry.dart';
import '../services/firebase_food_stats_history_service.dart';

/// Repository for calorie data
/// Abstracts Firebase access and provides a single source for food user_history.
class FoodStatsHistoryRepository {
  final _service = FirebaseFoodStatsHistoryService.instance;

  FoodStatsHistoryRepository._internal();
  static final instance = FoodStatsHistoryRepository._internal();

  /// Gives Dashboard data for current day
  /// Stream of [FoodStats] for a specific date.
  Stream<FoodStats?> watchCurrentDayDashboardFoodStats(DateTime date) {
    return _service.watchCurrentDayDashboardFoodStats(date);
  }

  /// Watches all [FoodStats] documents for a specific [year].
  /// User in User History page
  Stream<List<FoodStatsEntry>> watchYearStats({required int year}) {
    return _service.watchYearStats(year: year);
  }

  /// One-time fetch all [FoodStats] documents for a specific [year].
  /// User in User History page
  // Future<List<FoodStatsEntry>> getYearStats({
  //   required int year,
  // }) {
  //   return _service.getAllFoodStats(year: year);
  // }

  /// Deletes food stats for the specified date
  Future<void> deleteFoodStats({required DateTime date}) {
    return _service.deleteFoodStats(cardDateTime: date);
  }
}
