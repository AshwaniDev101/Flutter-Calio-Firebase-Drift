import 'dart:async';
import 'package:calio/models/consumed_diet_food.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../database/repository/consumed_diet_food_repository.dart';
import '../../../../database/repository/food_stats_history_repository.dart';
import '../../../../database/repository/global_diet_food_repository.dart';
import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';


class FoodManager {
  FoodManager._internal();
  static final FoodManager _instance = FoodManager._internal();
  static FoodManager get instance => _instance;

  final _dietFoodRepository = GlobalDietFoodRepository.instance;
  final _foodStatsHistoryRepository = FoodStatsHistoryRepository.instance;
  final _consumedDietFoodRepository = ConsumedDietFoodRepository.instance;


  /// Watches both available foods and consumed foods,
  /// and merges them into a single stream where each
  /// available food also contains its consumed count.
  Stream<List<DietFood>> watchMergedFoodList(DateTime dateTime) {
    return Rx.combineLatest2<List<DietFood>, List<ConsumedDietFood>, List<DietFood>>(
      _watchAvailableFood(),
      _watchConsumedFood(dateTime),
          (availableList, consumedList) {
        // Map consumed food by ID for quick lookup
        final consumedMap = {
          for (final food in consumedList) food.id: food,
        };

        // Merge available list with consumed count & time
        final mergedList = availableList.map((food) {
          final consumedFood = consumedMap[food.id];
          return food.copyWith(
            count: consumedFood?.count ?? 0,
            timestamp: consumedFood?.timestamp ?? food.timestamp,
          );
        }).toList();

        // Sort by timestamp descending (most recent first)
        // mergedList.sort((a, b) => b.time.compareTo(a.time));
        mergedList.sort((a, b) => a.name.compareTo(b.name));

        return mergedList;
      },
    );
  }



  Stream<List<DietFood>> _watchAvailableFood() {

    return _dietFoodRepository.watchAvailableFood();
  }
  Stream<List<ConsumedDietFood>> _watchConsumedFood(DateTime dateTime) {

    return _consumedDietFoodRepository.watchConsumedFood(dateTime);
  }


  Stream<FoodStats?> watchConsumedFoodStats(DateTime dateTime) {

    return _foodStatsHistoryRepository.watchFoodStats(dateTime);
  }


  // Add to available food list
  void addToAvailableFood(DietFood food) {
    _dietFoodRepository.addAvailable(food);
  }

  void changeConsumedCount(double count, ConsumedDietFood food, DateTime dateTime) {
    _consumedDietFoodRepository.changeConsumedCount(count,food, dateTime);

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
