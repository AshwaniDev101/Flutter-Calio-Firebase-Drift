import 'dart:async';
import 'package:rxdart/rxdart.dart';

import '../../../../database/repository/food_history_repository.dart';
import '../../../../database/repository/global_diet_food_repository.dart';
import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';


class FoodManager {
  FoodManager._internal();
  static final FoodManager _instance = FoodManager._internal();
  static FoodManager get instance => _instance;


  final _dietFoodRepository = GlobalDietFoodRepository.instance;



  /// Watches both available foods and consumed foods,
  /// and merges them into a single stream where each
  /// available food also contains its consumed count.
  Stream<List<DietFood>> watchMergedFoodList(DateTime dateTime) {
    return Rx.combineLatest2<List<DietFood>, List<DietFood>, List<DietFood>>(
      _watchAvailableFood(),  // Stream of all available foods
      _watchConsumedFood(dateTime),   // Stream of consumed foods
          (availableList, consumedList) {

        // Create a quick lookup map of consumed food counts by ID
        final consumedMap = {
          for (final food in consumedList) food.id: food.count,
        };

        // Merge the two lists:
        // For each available food, check if it exists in consumedMap
        // If yes, use its consumed count; otherwise, set count to 0
        return availableList.map((food) {
          final consumedCount = consumedMap[food.id] ?? 0;
          return food.copyWith(count: consumedCount);
        }).toList();
      },
    );
  }


  Stream<List<DietFood>> _watchAvailableFood() {

    return _dietFoodRepository.watchAvailableFood();
  }
  Stream<List<DietFood>> _watchConsumedFood(DateTime dateTime) {

    return _dietFoodRepository.watchConsumedFood(dateTime);
  }


  Stream<FoodStats?> watchConsumedFoodStats(DateTime dateTime) {

    return FoodHistoryRepository.instance.watchConsumedFoodStats(dateTime);
  }


  // Add to available food list
  void addToAvailableFood(DietFood food) {
    _dietFoodRepository.addAvailable(food);
  }

  void changeConsumedCount(double count, DietFood food, DateTime dateTime) {
    FoodHistoryRepository.instance.changeConsumedCount(count,food, dateTime);

  }

  // Remove from available food list
  void removeFromAvailableFood(DietFood food) {
    _dietFoodRepository.deleteAvailable(food.id);
  }

  // Edit available food
  void updateAvailableFood(DietFood food) {
    _dietFoodRepository.updateAvailable(food.id, food);
  }

}
