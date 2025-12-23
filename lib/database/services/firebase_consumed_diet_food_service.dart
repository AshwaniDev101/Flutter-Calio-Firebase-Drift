import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/consumed_diet_food.dart';
import '../../models/food_stats.dart';

class FirebaseConsumedDietFoodService {
  FirebaseConsumedDietFoodService._();

  static final instance = FirebaseConsumedDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  /// Watch consumed food list for a specific date
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime dateTime) {
    return _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        // .doc('${date.day}-${date.month}')
        .doc(DateTimeHelper.toDayMonthId(dateTime))
        .collection('food_consumed_list')
        .snapshots()
        .map((snapshot) {
      final List<ConsumedDietFood> list = [];
      for (final doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          final consumed = ConsumedDietFood.fromMap(data);
          list.add(consumed);
        } catch (e, s) {
          debugPrint('ConsumedDietFood parse failed: $e');
        }
      }
      return list;
    });
  }

  Future<void> updateConsumedFood(ConsumedDietFood newConsumedFoodItem, ConsumedDietFood oldConsumedFoodItem, DateTime dateTime) async {
    final dayMonthDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        // .doc('${dateTime.day}-${dateTime.month}');
        .doc(DateTimeHelper.toDayMonthId(dateTime));


    final consumedFoodDocRef = dayMonthDocRef
        .collection('food_consumed_list')
        .doc(newConsumedFoodItem.id);


    // Run as a transaction to ensure atomicity
    return _db.runTransaction((transaction) async {



      // 1. Get the current daily total stats
      final dailyStatsSnapshot = await transaction.get(dayMonthDocRef);
      FoodStats currentStats;
      if (dailyStatsSnapshot.exists && dailyStatsSnapshot.data()?['foodStats'] != null) {
        currentStats = FoodStats.fromMap(dailyStatsSnapshot.data()!['foodStats']);
      } else {
        currentStats = FoodStats.empty();
      }


      //
      // 2. Calculate the change in stats by finding the difference between the new and old items
      final statsDelta = newConsumedFoodItem.foodStats.subtract(oldConsumedFoodItem.foodStats);
      //
      // 3. Apply the delta to the current total stats to get the new total
      final FoodStats newTotalStats = currentStats.sum(statsDelta);
      //
      // 4. Update the individual consumed food item itself
      // Using .set() handles both creation and update scenarios.
      transaction.set(consumedFoodDocRef, newConsumedFoodItem.toMap());
      //
      // 5. Update the daily total stats document with the new aggregated value
      // transaction.set(
      //     dayMonthDocRef,newTotalStats.toMap(),
      //     // {
      //     //   // Only storing total calories in the daily summary for efficiency
      //     //   'foodStats': {'version': newTotalStats.version, 'calories': newTotalStats.calories},
      //     //   // 'timestamp': Timestamp.now(),
      //     //   // 'last_update_on': Timestamp.now(),
      //     // },
      //     SetOptions(merge: true));

      final isFirstCreate = !dailyStatsSnapshot.exists;

      transaction.set(
        dayMonthDocRef,
        {
          if (isFirstCreate) 'createdAt': Timestamp.now(),
          'foodStats': newTotalStats.toMap(),
          'lastUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );


    });


  }



  /// Atomically changes the consumed count for a food item and updates the
  /// daily total statistics within a Firestore transaction.
  ///
  /// [count] represents the delta (e.g., +1 for adding, -1 for removing).
  /// This ensures that the daily summary is always consistent with the individual
  /// food counts.
  Future<void> changeConsumedFoodCount(double count, ConsumedDietFood food, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        .doc(DateTimeHelper.toDayMonthId(dateTime));
        // .doc('${dateTime.day}-${dateTime.month}');


    final consumedFoodDocRef = dayDocRef.collection('food_consumed_list').doc(food.id);

    // Run as a transaction to ensure atomicity
    return _db.runTransaction((transaction) async {
      // 1. Get the current daily total stats
      final dailyStatsSnapshot = await transaction.get(dayDocRef);
      FoodStats currentStats;
      if (dailyStatsSnapshot.exists && dailyStatsSnapshot.data()?['foodStats'] != null) {
        currentStats = FoodStats.fromMap(dailyStatsSnapshot.data()!['foodStats']);
      } else {
        currentStats = FoodStats.empty();
      }

      // 2. Calculate the change in stats based on the food's stats per serving and the count delta
      final statsDelta = FoodStats(
        calories: food.foodStats.calories * count,
        // proteins: food.foodStats.proteins * count,
        // carbohydrates: food.foodStats.carbohydrates * count,
        // fats: food.foodStats.fats * count,
        // minerals: food.foodStats.minerals * count,
        // vitamins: food.foodStats.vitamins * count,
      );
      final FoodStats newTotalStats = currentStats.sum(statsDelta);

      // 3. Update the individual consumed food item's count
      final consumedFoodSnapshot = await transaction.get(consumedFoodDocRef);
      final foodMap = food.toMap()..remove('id');

      if (consumedFoodSnapshot.exists) {
        final double existingCount = consumedFoodSnapshot.data()?['count'] ?? 0;
        final newCount = existingCount + count;

        if (newCount > 0) {
          transaction.update(consumedFoodDocRef, {...foodMap, 'count': newCount});
        } else {
          // If count drops to 0 or below, remove the item from the consumed list
          transaction.delete(consumedFoodDocRef);
        }
      } else if (count > 0) {
        // If the item wasn't in the list and we're adding it, create it
        transaction.set(consumedFoodDocRef, {...foodMap, 'count': count});
      }

      // 4. Update the daily total stats document with the new aggregate
      // transaction.set(
      //     dayDocRef,
      //     {
      //       'foodStats': {'version': newTotalStats.version, 'calories': newTotalStats.calories},
      //       'timestamp': Timestamp.now(),
      //     },
      //     SetOptions(merge: true));



      final isFirstCreate = !dailyStatsSnapshot.exists;

      transaction.set(
        dayDocRef,
        {
          if (isFirstCreate) 'createdAt': Timestamp.now(),
          'foodStats': newTotalStats.toMap(),
          'lastUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
