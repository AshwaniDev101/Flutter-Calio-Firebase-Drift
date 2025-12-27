import 'package:calio/models/consumed_diet_food.dart';

import '../../models/diet_food.dart'; // Kept if needed elsewhere
import '../services/firebase/firestore_consumed_diet_food_service.dart';

/// Repository for managing daily consumed food items.
///
/// Provides a clean, abstracted interface over the Firebase service.
/// This layer ensures consistent method usage across the app and allows
/// future additions like local caching or validation without affecting UI code.
class ConsumedDietFoodRepository {
  final FirestoreConsumedDietFoodService _service =
      FirestoreConsumedDietFoodService.instance;

  ConsumedDietFoodRepository._internal();

  /// Singleton instance
  static final instance = ConsumedDietFoodRepository._internal();

  /// Watches for changes in the list of consumed food items for a specific date.
  ///
  /// Returns a real-time stream of [ConsumedDietFood] items.
  /// Emits an empty list if nothing has been consumed on that date.
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime date) {
    return _service.watchConsumedFood(date);
  }

  /// Change the consumed count of a specific food on a given date.
  ///
  /// [count] is the **delta** (positive to increase, negative to decrease).
  /// Handles creation, increment, decrement, and auto-deletion if count ≤ 0.
  /// Daily totals are updated atomically.
  Future<void> changeConsumedCount(
      double count,
      ConsumedDietFood food,
      DateTime date,
      ) {
    return _service.changeConsumedFoodCount(count, food, date);
  }

  /// Change the consumed count of a specific food on a given date.
  ///
  /// Fully replaces the consumed item and recalculates daily totals.
  /// Use this when editing the food type or custom nutrition values.
  Future<void> updateConsumedFood(
      ConsumedDietFood newConsumedFoodItem,
      ConsumedDietFood oldConsumedFoodItem,
      DateTime dateTime,
      ) {
    return _service.updateConsumedFood(
      newConsumedFoodItem,
      oldConsumedFoodItem,
      dateTime,
    );
  }
}