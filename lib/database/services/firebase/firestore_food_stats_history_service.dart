import 'package:calio/database/services/firebase/constants.dart';
import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/food_stats.dart';
import '../../../models/food_stats_entry.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie/food stats history data.
///
/// Data structure:
/// users/{userId}/history/{year}/data/{YYYY-MM-DD}
///   ├─ foodStats (map)
///   ├─ createdAt (timestamp)
///   ├─ lastUpdatedAt (timestamp)
///   └─ consumedList (subcollection)
class FirestoreFoodStatsHistoryService {
  FirestoreFoodStatsHistoryService._();

  static final instance = FirestoreFoodStatsHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TODO: Replace with dynamic user ID from FirebaseAuth
  final String _userId = 'user1';

  CollectionReference<Map<String, dynamic>> _yearDataCollection(int year) {
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('$year')
        .collection(FirestoreConstants.colData);
  }

  DocumentReference<Map<String, dynamic>> _dayDocument(DateTime date) {
    final dayId = DateTimeHelper.toDayMonthId(date);
    return _yearDataCollection(date.year).doc(dayId);
  }

  /// Gives Dashboard data for current day
  /// Stream of [FoodStats] for a specific date.
  /// Returns null if no data exists yet.
  Stream<FoodStats?> watchCurrentDayDashboardFoodStats(DateTime dateTime) {
    final docRef = _dayDocument(dateTime);

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null || data[FirestoreConstants.fieldFoodStats] == null) {
        return null;
      }

      return FoodStats.fromMap(
        Map<String, dynamic>.from(data[FirestoreConstants.fieldFoodStats]),
      );
    });
  }

  /// Watches all [FoodStats] documents for a specific [year].
  /// Used in User History page.
  /// Ordered by creation time descending (most recent first).
  Stream<List<FoodStatsEntry>> watchYearStats({required int year}) {
    final ref = _yearDataCollection(year)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodStatsEntry.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// One-time fetch all [FoodStats] documents for a specific [year].
  /// Used in User History page.
  Future<List<FoodStatsEntry>> getAllFoodStats({required int year}) async {
    final ref = _yearDataCollection(year)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true);

    final snapshot = await ref.get();

    return snapshot.docs.map((doc) {
      return FoodStatsEntry.fromMap(doc.id, doc.data());
    }).toList();
  }

  /// Permanently deletes the [FoodStats] document and its subcollections for a given date.
  /// Currently deletes only the consumedList subcollection.
  Future<void> deleteFoodStats({required DateTime cardDateTime}) async {
    final dayDocRef = _dayDocument(cardDateTime);
    final consumedColRef = dayDocRef.collection(FirestoreConstants.colConsumedList);

    // Delete subcollection in batches
    await _deleteSubcollectionInBatches(consumedColRef);

    // Delete the day document itself
    await dayDocRef.delete();
  }

  /// Helper: Deletes an entire subcollection in batches (Firestore limit: 500 ops per batch)
  Future<void> _deleteSubcollectionInBatches(CollectionReference collection) async {
    const int batchSize = 20;
    var snapshot = await collection.limit(batchSize).get();

    while (snapshot.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Get next batch
      snapshot = await collection.limit(batchSize).get();
    }
  }
}