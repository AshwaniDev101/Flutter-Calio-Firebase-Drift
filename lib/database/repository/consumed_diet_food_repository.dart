import 'package:calio/models/consumed_diet_food.dart';

import '../../models/diet_food.dart';
import '../services/firebase/firestore_consumed_diet_food_service.dart';


class ConsumedDietFoodRepository {
  ConsumedDietFoodRepository._internal();

  static final instance = ConsumedDietFoodRepository._internal();

  final _service = FirestoreConsumedDietFoodService.instance;

  /// Watches for changes in the list of consumed food items for a specific date.
  /// Returns a stream of [DietFood] lists.
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime date) {
    return _service.watchConsumedFood(date);
  }

  /// Get food stats for a full year
  /// Returns a map of { month : { day : FoodStats } }
  // Future<Map<int, Map<int, FoodStats>>> getYearStats({required int year}) {
  //   return _service.getFoodStatsForYear(year: year);
  // }

  /// Change the consumed count of a specific food on a given date
  Future<void> changeConsumedCount(double count, ConsumedDietFood food, DateTime date) {
    return _service.changeConsumedFoodCount(count, food, date);
  }

  /// Change the consumed count of a specific food on a given date
  Future<void> updateConsumedFood(ConsumedDietFood newConsumedFoodItem, ConsumedDietFood oldConsumedFoodItem, DateTime dateTime) {
    return _service.updateConsumedFood(newConsumedFoodItem,oldConsumedFoodItem, dateTime);
  }

}
