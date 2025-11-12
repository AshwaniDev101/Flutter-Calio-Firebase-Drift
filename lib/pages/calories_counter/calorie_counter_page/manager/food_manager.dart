import 'dart:async';
import 'package:calio/models/consumed_diet_food.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/logger.dart';
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
      _watchGlobalDietFood(),
      _watchConsumedFood(dateTime),
          (globalDietFoodList, consumedDietFoodList) {
        final Map<String, DietFood> globalMap = {
          for (final g in globalDietFoodList) g.id: g
        };
        final Map<String, ConsumedDietFood> consumedMap = {
          for (final c in consumedDietFoodList) c.id: c
        };

        final Set<String> allIds = {
          ...globalMap.keys,
          ...consumedMap.keys,
        };

        final List<DietFood> mergedList = allIds.map((id) {
          final gFood = globalMap[id];
          final consumed = consumedMap[id];

          // only in global
          if (gFood != null && consumed == null) return gFood;

          // only in consumed
          if (gFood == null && consumed != null) {
            Log.w("⚠️ Consumed item missing globally: $id");
            return DietFood(id: consumed.id, name: 'Deleted', timestamp: consumed.timestamp, foodStats: consumed.foodStats,count: consumed.count);
          }

          // both exist -> merge
          if (gFood != null && consumed != null) {
            if (gFood.foodStats.calories != consumed.foodStats.calories) {
              Log.e("❗ Mismatch for ${gFood.name} (ID: $id)");
              fixMissMatch(gFood, consumed, dateTime);
            }

            return gFood.copyWith(
              count: consumed.count,
              timestamp: consumed.timestamp,
            );
          }

          // logically unreachable
          throw StateError("Invalid merge state for ID: $id");
        }).toList();

        mergedList.sort((a, b) => a.name.compareTo(b.name));

        Log.i("---- ✅ Merge Complete G|C[${globalDietFoodList.length}|${consumedDietFoodList.length}] ----");
        return mergedList;
      },
    );
  }

  // Stream<List<DietFood>> watchMergedFoodList(DateTime dateTime) {
  //   return Rx.combineLatest2<List<DietFood>, List<ConsumedDietFood>, List<DietFood>>(
  //     _watchGlobalDietFood(),
  //     _watchConsumedFood(dateTime),
  //         (globalDietFoodList, consumedDietFoodList) {
  //       // print("---- 🔄 Merging Global and Consumed Lists ----");
  //       // print("Global List Count: ${globalDietFoodList.length}");
  //       // print("Consumed List Count: ${consumedDietFoodList.length}");
  //
  //       // creating a map of consumed foods for easy lookup
  //       final Map<String, ConsumedDietFood> consumedDietFoodMap = {
  //         for (final food in consumedDietFoodList) food.id: food
  //       };
  //
  //       final List<DietFood> mergedList = globalDietFoodList.map((gFood) {
  //         final ConsumedDietFood? consumed = consumedDietFoodMap[gFood.id];
  //         if (consumed == null) {
  //           // print("⚠️ No consumed entry found for ID: ${gFood.id}");
  //           return gFood;
  //         }
  //
  //         final gc = gFood.foodStats.calories;
  //         final cc = consumed.foodStats.calories;
  //
  //         if (gc != cc) {
  //
  //          Log.e("❗ Mismatch Detected for ${gFood.name} (ID: ${gFood.id})");
  //          Log.e("Calories $gc != $cc)");
  //
  //           fixMissMatch(gFood,consumed,dateTime);
  //         }
  //
  //         return gFood.copyWith(
  //           count: consumed.count,
  //           timestamp: consumed.timestamp,
  //         );
  //       }).toList();
  //
  //       Log.i("---- ✅ Merge Complete G|C[${globalDietFoodList.length}|${consumedDietFoodList.length}] ----");
  //       mergedList.sort((a, b) => a.name.compareTo(b.name));
  //
  //       return mergedList;
  //     },
  //   );
  // }

  Stream<List<DietFood>> _watchGlobalDietFood() {
    return _dietFoodRepository.watchGlobalFoodList();
  }

  Stream<List<ConsumedDietFood>> _watchConsumedFood(DateTime dateTime) {
    return _consumedDietFoodRepository.watchConsumedFood(dateTime);
  }

  Stream<FoodStats?> watchConsumedFoodStats(DateTime dateTime) {
    return _foodStatsHistoryRepository.watchFoodStats(dateTime);
  }

  // Add to available food list
  void addToAvailableFood(DietFood food) {
    _dietFoodRepository.addToGlobalFoodList(food);
  }

  void changeConsumedCount(double count, ConsumedDietFood food, DateTime dateTime) {
    _consumedDietFoodRepository.changeConsumedCount(count, food, dateTime);
  }

  // Remove from available food list
  void removeFromAvailableFood(DietFood food) {
    _dietFoodRepository.deleteToGlobalFoodList(food.id);
  }

  // Edit available food
  void updateAvailableFood(DietFood food) {
    _dietFoodRepository.updateToGlobalFoodList(food.id, food);
  }

  void fixMissMatch(DietFood globalFoodItem, ConsumedDietFood consumedFoodItem, DateTime dateTime)
  {
    // first fix the value in the consumed foodStats
    final oldConsumedFoodItem = consumedFoodItem;
    final newConsumedFoodItem = ConsumedDietFood.fromDietFood(globalFoodItem);

    _consumedDietFoodRepository.updateConsumedFood(newConsumedFoodItem, oldConsumedFoodItem, dateTime);


    // fix the total foodstats



  }

}
