import 'package:calio/database/services/firebase/constants.dart';
import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../models/consumed_diet_food.dart';
import '../../../models/food_stats.dart';

/// A dedicated service for managing consumed food records in Firebase Firestore.
class FirestoreConsumedDietFoodService {
  FirestoreConsumedDietFoodService._();

  static final instance = FirestoreConsumedDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId = 'user1'; // TODO: Replace with dynamic user ID

  /// Returns a real-time [Stream] of [ConsumedDietFood] items for a specific [dateTime].
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime dateTime) {
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('${dateTime.year}')
        .collection(FirestoreConstants.colData)
        .doc(DateTimeHelper.toDayMonthId(dateTime))
        .collection(FirestoreConstants.colConsumedList)
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
  Future<void> updateConsumedFood(ConsumedDietFood newItem, ConsumedDietFood oldItem, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('${dateTime.year}')
        .collection(FirestoreConstants.colData)
        .doc(DateTimeHelper.toDayMonthId(dateTime));

    final foodDocRef = dayDocRef.collection(FirestoreConstants.colConsumedList).doc(newItem.id);

    return _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);
      FoodStats currentStats = dailySnapshot.exists && dailySnapshot.data()?[FirestoreConstants.fieldFoodStats] != null
          ? FoodStats.fromMap(dailySnapshot.data()![FirestoreConstants.fieldFoodStats])
          : FoodStats.empty();

      final deltaCalories = (newItem.foodStats.calories * newItem.count) - (oldItem.foodStats.calories * oldItem.count);
      final newTotalStats = FoodStats(calories: currentStats.calories + deltaCalories);

      transaction.set(foodDocRef, newItem.toMap());
      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists) FirestoreConstants.fieldCreatedAt: Timestamp.now(),
          FirestoreConstants.fieldFoodStats: newTotalStats.toMap(),
          FirestoreConstants.fieldLastUpdatedAt: Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Adjusts the quantity of a consumed food item and updates daily totals atomically.
  Future<void> changeConsumedFoodCount(double deltaCount, ConsumedDietFood food, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('${dateTime.year}')
        .collection(FirestoreConstants.colData)
        .doc(DateTimeHelper.toDayMonthId(dateTime));

    final foodDocRef = dayDocRef.collection(FirestoreConstants.colConsumedList).doc(food.id);
    final deltaCalories = food.foodStats.calories * deltaCount;

    return _db.runTransaction((transaction) async {
      final dailySnapshot = await transaction.get(dayDocRef);
      final foodSnapshot = await transaction.get(foodDocRef);

      if (foodSnapshot.exists) {
        final double currentCount = (foodSnapshot.data()?[FirestoreConstants.fieldCount] ?? 0).toDouble();
        final double nextCount = currentCount + deltaCount;

        if (nextCount <= 0) {
          transaction.delete(foodDocRef);
        } else {
          transaction.update(foodDocRef, {
            FirestoreConstants.fieldCount: FieldValue.increment(deltaCount),
            FirestoreConstants.fieldLastUpdatedAt: Timestamp.now(),
          });
        }
      } else if (deltaCount > 0) {
        transaction.set(foodDocRef, {
          ...food.toMap()..remove('id'),
          FirestoreConstants.fieldCount: deltaCount,
          FirestoreConstants.fieldCreatedAt: Timestamp.now(),
          FirestoreConstants.fieldLastUpdatedAt: Timestamp.now(),
        });
      }

      transaction.set(
        dayDocRef,
        {
          if (!dailySnapshot.exists) FirestoreConstants.fieldCreatedAt: Timestamp.now(),
          FirestoreConstants.fieldFoodStats: {
            FirestoreConstants.fieldCalories: FieldValue.increment(deltaCalories),
            FirestoreConstants.fieldVersion: 1,
          },
          FirestoreConstants.fieldLastUpdatedAt: Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
