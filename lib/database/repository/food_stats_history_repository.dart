

import '../../models/food_stats.dart';
import '../../models/food_stats_entry.dart';
import '../services/firebase_food_stats_history_service.dart';

/// Repository for calorie data
/// Abstracts Firebase access and provides a single source for food user_history.
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
  Future<List<FoodStatsEntry>> getYearStats({
    required int year,
  }) {
    return _service.getAllFoodStats(year: year);
  }


  /// Deletes food stats for the specified date
  Future<void> deleteFoodStats({required DateTime date}) {
    return _service.deleteFoodStats(cardDateTime: date);
  }
}
