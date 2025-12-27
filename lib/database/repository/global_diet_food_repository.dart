import '../../models/diet_food.dart';
import '../services/firebase/firestore_global_diet_food_service.dart';

/// Repository for managing the user's global list of available diet foods.
///
/// Provides a clean abstraction over the Firebase service.
/// Allows consistent usage across the app and makes future extensions
/// (e.g., local caching, validation, or alternative backends) easier.
class GlobalDietFoodRepository {
  final FirestoreGlobalDietFoodService _service =
      FirestoreGlobalDietFoodService.instance;

  GlobalDietFoodRepository._internal();

  /// Singleton instance
  static final instance = GlobalDietFoodRepository._internal();

  /// Watches for changes in the list of available food items.
  ///
  /// Returns a real-time stream of [DietFood] lists.
  /// Emits an empty list if no foods exist yet.
  Stream<List<DietFood>> watchGlobalFoodList() {
    return _service.watchGlobalFoodList();
  }

  /// Adds a new food item to the list of available food.
  ///
  /// Uses the food's own [DietFood.id] as the document ID.
  Future<void> addToGlobalFoodList(DietFood food) {
    return _service.addGlobalFoodList(food);
  }

  /// Updates an existing food item in the list of available food.
  ///
  /// Performs a partial update of the provided fields.
  Future<void> updateToGlobalFoodList(String id, DietFood food) {
    return _service.updateInGlobalFoodListItem(id, food);
  }

  /// Deletes a food item from the list of available food.
  Future<void> deleteToGlobalFoodList(String id) {
    return _service.deleteFromGlobalFoodList(id);
  }

  /// Convenience upsert: adds the food if it doesn't exist, updates if it does.
  ///
  /// Ideal for edit forms where you don't need to know whether the item is new.
  Future<void> upsertGlobalFood(DietFood food) {
    return _service.upsertGlobalFood(food);
  }
}