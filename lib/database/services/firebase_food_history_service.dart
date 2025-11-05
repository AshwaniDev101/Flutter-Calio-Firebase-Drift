
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../models/diet_food.dart';
import '../../models/food_stats.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie history data.
class FirebaseFoodHistoryService {
  FirebaseFoodHistoryService._();
  static final instance = FirebaseFoodHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  /// Watches for real-time changes to the [FoodStats] for a specific [date].
  ///
  /// This method is pure and has no side-effects. It returns a stream
  /// that provides the latest [FoodStats] from Firestore or null if none exists.
  Stream<FoodStats?> watchDietStatistics(DateTime date) {
    final ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}');

    return ref.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['foodStats'] != null) {
          return FoodStats.fromMap(Map<String, dynamic>.from(data['foodStats']));
        }
      }
      return null;
    });
  }

  /// Atomically changes the consumed count for a food item and updates the
  /// daily total statistics within a Firestore transaction.
  ///
  /// [count] represents the delta (e.g., +1 for adding, -1 for removing).
  /// This ensures that the daily summary is always consistent with the individual
  /// food counts.
  Future<void> changeConsumedFoodCount(double count, DietFood food, DateTime dateTime) async {



    final dayDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('${dateTime.month}')
        .doc('${dateTime.day}');


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
        proteins: food.foodStats.proteins * count,
        carbohydrates: food.foodStats.carbohydrates * count,
        fats: food.foodStats.fats * count,
        minerals: food.foodStats.minerals * count,
        vitamins: food.foodStats.vitamins * count,
      );
      final newTotalStats = currentStats.sum(statsDelta);

      // 3. Update the individual consumed food item's count
      final consumedFoodSnapshot = await transaction.get(consumedFoodDocRef);
      final foodMap = food.toConsumedMap()..remove('id');

      if (consumedFoodSnapshot.exists) {
        final existingCount = consumedFoodSnapshot.data()?['count'] ?? 0;
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
      transaction.set(dayDocRef, {'foodStats': newTotalStats.toMap()}, SetOptions(merge: true));
    });
  }


  /// Retrieves all stored [FoodStats] documents for a specific [year] and [month].
  Future<Map<int, FoodStats>> getFoodStatsForMonth({
    required int year,
    required int month,
  }) async {
    final monthRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString())
        .collection(month.toString());

    final snapshot = await monthRef.get();
    final Map<int, FoodStats> statsMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final day = int.tryParse(doc.id);

      if (day != null && data['foodStats'] != null) {
        try {
          statsMap[day] = FoodStats.fromMap(data['foodStats']);
        } catch (e) {
          debugPrint('Invalid foodStats data for day $day: $e');
        }
      }
    }

    final reversedMap = Map.fromEntries(
      statsMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return reversedMap;
  }

  /// Retrieves the complete set of [FoodStats] for an entire [year].
  Future<Map<int, Map<int, FoodStats>>> getFoodStatsForYear({
    required int year,
  }) async {
    final yearRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString());

    final Map<int, Map<int, FoodStats>> yearlyStats = {};

    final monthFutures = List.generate(12, (index) async {
      final month = index + 1;
      final monthRef = yearRef.collection(month.toString());
      final snapshot = await monthRef.get();

      final Map<int, FoodStats> monthMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final day = int.tryParse(doc.id);

        if (day != null && data['foodStats'] != null) {
          try {
            monthMap[day] = FoodStats.fromMap(data['foodStats']);
          } catch (_) {}
        }
      }

      if (monthMap.isNotEmpty) yearlyStats[month] = monthMap;
    });

    await Future.wait(monthFutures);
    return yearlyStats;
  }

  /// Updates or creates the [FoodStats] record for a specific day.
  Future<void> updateFoodStats({
    required DateTime cardDateTime,
    required FoodStats foodStats,
  }) async {
    var ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection(cardDateTime.month.toString())
        .doc(cardDateTime.day.toString());

    await ref.set(
      {'foodStats': foodStats.toMap()},
      SetOptions(merge: true),
    );
  }

  /// Permanently deletes the [FoodStats] document and its subcollections for a given date.
  Future<void> deleteFoodStats({required DateTime cardDateTime}) async {
    final docRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection(cardDateTime.month.toString())
        .doc(cardDateTime.day.toString());

    final subColRef = docRef.collection('food_consumed_list');
    const int batchSize = 20;

    Future<void> deleteSubcollectionBatch() async {
      var snapshot = await subColRef.limit(batchSize).get();
      while (snapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        snapshot = await subColRef.limit(batchSize).get();
      }
    }
    await deleteSubcollectionBatch();
    await docRef.delete();
  }
}
