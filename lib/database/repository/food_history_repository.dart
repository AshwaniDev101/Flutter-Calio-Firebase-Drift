
import '../../database/services/firebase_food_history_service.dart';
import '../../models/diet_food.dart';
import '../../models/food_stats.dart';

/// Repository for calorie data
/// Abstracts Firebase access and provides a single source for food history.
class FoodHistoryRepository {
  final _service = FirebaseFoodHistoryService.instance;

  FoodHistoryRepository._internal();

  static final instance = FoodHistoryRepository._internal();

  /// Stream of consumed food stats for a specific date
  Stream<FoodStats?> watchConsumedFoodStats(DateTime date) {
    return _service.watchDietStatistics(date);
  }

  /// Get food stats for a specific month
  Future<Map<int, FoodStats>> getMonthStats({
    required int year,
    required int month,
  }) {
    return _service.getFoodStatsForMonth(year: year, month: month);
  }

  /// Get food stats for a full year
  /// Returns a map of { month : { day : FoodStats } }
  Future<Map<int, Map<int, FoodStats>>> getYearStats({required int year}) {
    return _service.getFoodStatsForYear(year: year);
  }

  /// Change the consumed count of a specific food on a given date
  Future<void> changeConsumedCount(double count, DietFood food, DateTime date) {
    return _service.changeConsumedFoodCount(count, food, date);
  }

  /// Deletes food stats for the specified date
  Future<void> deleteFoodStats({required DateTime date}) {
    return _service.deleteFoodStats(cardDateTime: date);
  }
}
