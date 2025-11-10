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
  // Stream<List<DietFood>> watchMergedFoodList(DateTime dateTime) {
  //
  //   return Rx.combineLatest2<List<DietFood>, List<ConsumedDietFood>, List<DietFood>>(
  //     _watchGlobalDietFood(),
  //     _watchConsumedFood(dateTime),
  //         (List<DietFood> globalDietFoodList, List<ConsumedDietFood> consumedDietFoodList) {
  //       // Map consumed food by ID for quick lookup
  //           final Map<String, ConsumedDietFood> consumedDietFoodMap = {};
  //
  //           for (var cFood in consumedDietFoodList) {
  //             consumedDietFoodMap[cFood.id] = cFood;
  //
  //             print("consumedDietFoodMap ${cFood.id}");
  //           }
  //
  //       // Merge available list with consumed count & time
  //           final mergedList = <DietFood>[];
  //
  //           for (var gFood in globalDietFoodList) {
  //
  //             print("globalDietFoodList ${gFood.name}");
  //
  //             final consumed = consumedDietFoodMap[gFood.id];
  //             mergedList.add(
  //               gFood.copyWith(
  //                 count: consumed?.count ?? 0,
  //                 timestamp: consumed?.timestamp ?? gFood.timestamp,
  //               ),
  //             );
  //           }
  //
  //
  //
  //       for (var e in mergedList) {
  //         print("mergedList ${e.name}");
  //       }
  //
  //       // Sort by timestamp descending (most recent first)
  //       // mergedList.sort((a, b) => b.time.compareTo(a.time));
  //       mergedList.sort((a, b) => a.name.compareTo(b.name));
  //
  //       return mergedList;
  //     },
  //   );
  // }

  Stream<List<DietFood>> watchMergedFoodList(DateTime dateTime) {
    print('=== watchMergedFoodList called with dateTime: $dateTime');

    return Rx.combineLatest2<List<DietFood>, List<ConsumedDietFood>, List<DietFood>>(
      _watchGlobalDietFood(),
      _watchConsumedFood(dateTime),
          (List<DietFood> globalDietFoodList, List<ConsumedDietFood> consumedDietFoodList) {
        print('=== combineLatest fired');
        print('=== globalDietFoodList length: ${globalDietFoodList.length}');
        print('=== consumedDietFoodList length: ${consumedDietFoodList.length}');

        // Map consumed food by ID for quick lookup
        final Map<String, ConsumedDietFood> consumedDietFoodMap = {};
        for (var cFood in consumedDietFoodList) {
          final id = cFood.id;
          print('=== consumed item -> id: $id, count: ${cFood.count}, timestamp: ${cFood.timestamp}');
          if (id != null) {
            consumedDietFoodMap[id] = cFood;
          } else {
            print('=== WARNING: consumed item has null id: $cFood');
          }
        }

        // Merge available list with consumed count & time
        final mergedList = <DietFood>[];
        for (var gFood in globalDietFoodList) {
          print('=== global item -> id: ${gFood.id}, name: ${gFood.name}, timestamp: ${gFood.timestamp}');
          final consumed = (gFood.id != null) ? consumedDietFoodMap[gFood.id] : null;

          final merged = gFood.copyWith(
            count: consumed?.count ?? 0,
            timestamp: consumed?.timestamp ?? gFood.timestamp,
          );

          print('=== merged item -> id: ${merged.id}, name: ${merged.name}, count: ${merged.count}, timestamp: ${merged.timestamp}');
          mergedList.add(merged);
        }

        print('=== mergedList total: ${mergedList.length}');

        // Sort by timestamp descending (most recent first).
        // Use safe fallback if timestamp is null.
        DateTime _safeTs(DateTime? t) => t ?? DateTime.fromMillisecondsSinceEpoch(0);

        // mergedList.sort((a, b) => _safeTs(b.name).compareTo(_safeTs(a.timestamp)));

        print('=== after sort (top 10):');
        for (var i = 0; i < mergedList.length && i < 10; i++) {
          final e = mergedList[i];
          print('#$i -> id:${e.id} name:${e.name} count:${e.count} ts:${e.timestamp}');
        }

        return mergedList;
      },
    );
  }


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
    _consumedDietFoodRepository.changeConsumedCount(count,food, dateTime);

  }

  // Remove from available food list
  void removeFromAvailableFood(DietFood food) {
    _dietFoodRepository.deleteToGlobalFoodList(food.id);
  }

  // Edit available food
  void updateAvailableFood(DietFood food) {
    _dietFoodRepository.updateToGlobalFoodList(food.id, food);
  }

}
