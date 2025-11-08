

import '../../models/diet_food.dart';
import '../../models/food_stats.dart';
import '../services/firebase_food_stats_history_service.dart';

/// Repository for calorie data
/// Abstracts Firebase access and provides a single source for food history.
class FoodStatsHistoryRepository {
  final _service = FirebaseFoodStatsHistoryService.instance;

  FoodStatsHistoryRepository._internal();
  static final instance = FoodStatsHistoryRepository._internal();

  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final String _root = 'users';
  // final String _userId = 'user1';


  /// Stream of consumed food stats for a specific date
  Stream<FoodStats?> watchFoodStats(DateTime date) {
    return _service.watchFoodStatus(date);
  }

  /// Get food stats for a specific month
  Future<Map<String, FoodStats>> getMonthStats({
    required int year,
    required int month,
  }) {
    return _service.getFoodStatsForMonth(year: year, month: month);
  }


  /// Deletes food stats for the specified date
  Future<void> deleteFoodStats({required DateTime date}) {
    return _service.deleteFoodStats(cardDateTime: date);
  }
}
