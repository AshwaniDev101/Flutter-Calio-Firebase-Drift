import '../../models/food_stats.dart';
import '../../models/food_stats_entry.dart';
import '../services/firebase/firestore_food_stats_history_service.dart';

/// Repository for managing user's food stats history.
///
/// Acts as an abstraction layer over the Firebase service, providing a clean
/// and consistent interface for the rest of the app (ViewModels, UI, etc.).
///
/// This allows future enhancements like local caching or offline support
/// without changing call sites.
class FoodStatsHistoryRepository {
  final FirestoreFoodStatsHistoryService _service =
      FirestoreFoodStatsHistoryService.instance;

  FoodStatsHistoryRepository._internal();

  /// Singleton instance
  static final instance = FoodStatsHistoryRepository._internal();

  /// Gives Dashboard data for current day
  /// Stream of [FoodStats] for a specific date.
  /// Emits null if no data exists yet for that date.
  Stream<FoodStats?> watchCurrentDayDashboardFoodStats(DateTime date) {
    return _service.watchCurrentDayDashboardFoodStats(date);
  }

  /// Watches all [FoodStats] documents for a specific [year].
  /// Used in User History page.
  /// Ordered from most recent to oldest.
  Stream<List<FoodStatsEntry>> watchYearStats({required int year}) {
    return _service.watchYearStats(year: year);
  }

  /// One-time fetch all [FoodStats] documents for a specific [year].
  /// Useful for initial load or when real-time updates are not needed.
  Future<List<FoodStatsEntry>> getAllFoodStats({required int year}) async {
    return _service.getAllFoodStats(year: year);
  }

  /// Deletes food stats for the specified date
  /// Permanently removes the day document and its consumedList subcollection.
  Future<void> deleteFoodStats({required DateTime date}) {
    return _service.deleteFoodStats(cardDateTime: date);
  }
}