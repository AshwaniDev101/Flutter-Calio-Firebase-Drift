import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/consumed_diet_food.dart';
import '../../models/food_stats.dart';

/// A dedicated service for managing consumed food records in Firebase Firestore.
///
/// This service handles real-time tracking of consumed items and maintains
/// aggregated daily statistics (e.g., total calories) using atomic operations
/// to ensure data consistency.
class FirebaseConsumedDietFoodService {
  FirebaseConsumedDietFoodService._();

  /// Singleton instance of the service.
  static final instance = FirebaseConsumedDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1'; // TODO: Replace with dynamic user ID

  /// Returns a real-time [Stream] of [ConsumedDietFood] items for a specific [dateTime].
  ///
  /// Listens to the 'food_consumed_list' subcollection for the given day.
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime dateTime) {
    return _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
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
        } catch (e) {
          debugPrint('ConsumedDietFood parse failed: $e');
        }
      }
      return list;
    });
  }

  /// Updates an existing consumed food item and recalculates the daily total stats.
  ///
  /// Uses a Firestore transaction to ensure that the individual item update
  /// and the aggregate daily total update happen atomically.
  ///
  /// [newItem] contains the updated food data.
  /// [oldItem] is used to calculate the difference (delta) in calories.
  /// [dateTime] specifies the day the food was consumed.
  Future<void> updateConsumedFood(ConsumedDietFood newItem, ConsumedDietFood oldItem, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        .doc(DateTimeHelper.toDayMonthId(dateTime));

    final foodDocRef = dayDocRef.collection('food_consumed_list').doc(newItem.id);

    return _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);
      FoodStats currentStats = dailySnapshot.exists && dailySnapshot.data()?['foodStats'] != null
          ? FoodStats.fromMap(dailySnapshot.data()!['foodStats'])
          : FoodStats.empty();

      // Calculate the net change in calories based on the change in food stats or count.
      final deltaCalories = (newItem.foodStats.calories * newItem.count) - (oldItem.foodStats.calories * oldItem.count);
      final newTotalStats = FoodStats(calories: currentStats.calories + deltaCalories);

      transaction.set(foodDocRef, newItem.toMap());
      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists) 'createdAt': Timestamp.now(),
          'foodStats': newTotalStats.toMap(),
          'lastUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Adjusts the quantity of a consumed food item and updates daily totals atomically.
  ///
  /// Employs [FieldValue.increment] within a transaction to prevent data drift
  /// during rapid UI interactions (concurrency safe). If the resulting count
  /// is zero or less, the item is removed from the list.
  ///
  /// [deltaCount] is the change in quantity (e.g., 1.0 or -1.0).
  /// [food] is the target food item.
  /// [dateTime] is the date for the consumption record.
  Future<void> changeConsumedFoodCount(double deltaCount, ConsumedDietFood food, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        .doc(DateTimeHelper.toDayMonthId(dateTime));

    final foodDocRef = dayDocRef.collection('food_consumed_list').doc(food.id);
    final deltaCalories = food.foodStats.calories * deltaCount;

    return _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);
      final foodSnapshot = await transaction.get(foodDocRef);

      // 1. Manage the individual food entry (Update, Create, or Delete).
      if (foodSnapshot.exists) {
        final double currentCount = (foodSnapshot.data()?['count'] ?? 0).toDouble();
        final double nextCount = currentCount + deltaCount;

        if (nextCount <= 0) {
          // Remove item if quantity drops to zero.
          transaction.delete(foodDocRef);
        } else {
          // Increment count atomically on the server.
          transaction.update(foodDocRef, {
            'count': FieldValue.increment(deltaCount),
            'lastUpdatedAt': Timestamp.now(),
          });
        }
      } else if (deltaCount > 0) {
        // Create new record if it doesn't exist yet.
        transaction.set(foodDocRef, {
          ...food.toMap()..remove('id'),
          'count': deltaCount,
          'createdAt': Timestamp.now(),
          'lastUpdatedAt': Timestamp.now(),
        });
      }

      // 2. Update the daily summary statistics atomically.
      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists) 'createdAt': Timestamp.now(),
          'foodStats': {
            'calories': FieldValue.increment(deltaCalories),
            'version': 1,
          },
          'lastUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
