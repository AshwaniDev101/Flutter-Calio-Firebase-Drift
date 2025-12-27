import 'package:calio/database/services/firebase/constants.dart';
import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/consumed_diet_food.dart';
import '../../../models/food_stats.dart';

/// A dedicated service for managing consumed food records in Firebase Firestore.
///
/// Data structure:
/// users/{userId}/history/{year}/data/{YYYY-MM-DD}/consumedList/{itemId}
///
/// Handles real-time streaming and atomic updates to consumed items
/// and the parent day's total stats.
class FirestoreConsumedDietFoodService {
  FirestoreConsumedDietFoodService._();

  static final instance = FirestoreConsumedDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TODO: Replace with dynamic user ID from FirebaseAuth
  final String _userId = 'user1';

  DocumentReference<Map<String, dynamic>> _dayDocument(DateTime date) {
    final dayId = DateTimeHelper.toDayMonthId(date);
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('${date.year}')
        .collection(FirestoreConstants.colData)
        .doc(dayId);
  }

  CollectionReference<Map<String, dynamic>> _consumedCollection(DateTime date) {
    return _dayDocument(date).collection(FirestoreConstants.colConsumedList);
  }

  /// Returns a real-time [Stream] of [ConsumedDietFood] items for a specific [dateTime].
  ///
  /// Returns an empty list if no items exist.
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime dateTime) {
    return _consumedCollection(dateTime).snapshots().map((snapshot) {
      final List<ConsumedDietFood> list = [];

      for (final doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          final consumed = ConsumedDietFood.fromMap(data);
          list.add(consumed);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('ConsumedDietFood parse failed (id: ${doc.id}): $e');
          }
        }
      }

      return list;
    });
  }

  /// Updates an existing consumed food item and recalculates the daily total stats.
  ///
  /// Replaces the entire item and adjusts the daily calorie total based on the difference.
  Future<void> updateConsumedFood(
      ConsumedDietFood newItem,
      ConsumedDietFood oldItem,
      DateTime dateTime,
      ) async {
    final dayDocRef = _dayDocument(dateTime);
    final foodDocRef = _consumedCollection(dateTime).doc(newItem.id);

    await _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);

      final currentStats = dailySnapshot.exists &&
          dailySnapshot.data()?['foodStats'] != null
          ? FoodStats.fromMap(dailySnapshot.data()!['foodStats'])
          : FoodStats.empty();

      final deltaCalories = (newItem.foodStats.calories * newItem.count) -
          (oldItem.foodStats.calories * oldItem.count);

      final newTotalStats =
      FoodStats(calories: currentStats.calories + deltaCalories);

      // Update consumed item (full replace)
      transaction.set(foodDocRef, newItem.toMap()..remove('id'));

      // Update daily stats
      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists)
            FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
          FirestoreConstants.fieldFoodStats: newTotalStats.toMap(),
          FirestoreConstants.fieldLastUpdatedAt: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Adjusts the quantity of a consumed food item and updates daily totals atomically.
  ///
  /// Handles creation, increment, decrement, and auto-deletion when count ≤ 0.
  Future<void> changeConsumedFoodCount(
      double deltaCount,
      ConsumedDietFood food,
      DateTime dateTime,
      ) async {
    if (deltaCount == 0) return;

    final dayDocRef = _dayDocument(dateTime);
    final foodDocRef = _consumedCollection(dateTime).doc(food.id);
    final deltaCalories = food.foodStats.calories * deltaCount;

    await _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);
      final foodSnapshot = await transaction.get(foodDocRef);

      // Handle the consumed item
      if (foodSnapshot.exists) {
        final currentCount =
        (foodSnapshot.data()?['count'] ?? 0.0).toDouble();
        final nextCount = currentCount + deltaCount;

        if (nextCount <= 0) {
          transaction.delete(foodDocRef);
        } else {
          transaction.update(foodDocRef, {
            'count': FieldValue.increment(deltaCount),
            FirestoreConstants.fieldLastUpdatedAt: FieldValue.serverTimestamp(),
          });
        }
      } else if (deltaCount > 0) {
        // Create new item
        final map = food.toMap()..remove('id');
        map['count'] = deltaCount;
        map[FirestoreConstants.fieldCreatedAt] = FieldValue.serverTimestamp();
        map[FirestoreConstants.fieldLastUpdatedAt] = FieldValue.serverTimestamp();

        transaction.set(foodDocRef, map);
      }

      // Update daily calorie total (only if there's a change)
      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists)
            FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
          '${FirestoreConstants.fieldFoodStats}.${FirestoreConstants.fieldCalories}':
          FieldValue.increment(deltaCalories),
          FirestoreConstants.fieldLastUpdatedAt: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}