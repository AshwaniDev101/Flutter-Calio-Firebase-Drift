
import '../../models/diet_food.dart';
import '../services/firebase_global_diet_food_service.dart';

/// A repository for managing global diet food data.
/// This class provides a singleton instance to interact with the Firebase global diet food service.
class GlobalDietFoodRepository {
  final _service = FirebaseGlobalDietFoodService.instance;

  GlobalDietFoodRepository._internal();

  static final instance = GlobalDietFoodRepository._internal();

  /// Watches for changes in the list of available food items.
  /// Returns a stream of [DietFood] lists.
  Stream<List<DietFood>> watchAvailableFood() {
    return _service.watchGlobalFoodList();
  }

  /// Watches for changes in the list of consumed food items for a specific date.
  /// Returns a stream of [DietFood] lists.
  Stream<List<DietFood>> watchConsumedFood(DateTime date) {
    return _service.watchConsumedFood(date);
  }

  /// Adds a new food item to the list of available food.
  Future<void> addAvailable(DietFood food) {
    return _service.addGlobalFoodList(food);
  }

  /// Updates an existing food item in the list of available food.
  Future<void> updateAvailable(String id, DietFood food) {
    return _service.updateInGlobalFoodListItem(id, food);
  }

  /// Deletes a food item from the list of available food.
  Future<void> deleteAvailable(String id) {
    return _service.deleteFromGlobalFoodList(id);
  }
}
