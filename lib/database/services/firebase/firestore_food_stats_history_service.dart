import 'package:calio/database/services/firebase/constants.dart';
import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/food_stats.dart';
import '../../../models/food_stats_entry.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie history data.
class FirestoreFoodStatsHistoryService {
  FirestoreFoodStatsHistoryService._();

  static final instance = FirestoreFoodStatsHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId = 'user1';

  /// Gives Dashboard data for current day
  /// Stream of [FoodStats] for a specific date.
  Stream<FoodStats?> watchCurrentDayDashboardFoodStats(DateTime dateTime) {
    final ref = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('${dateTime.year}')
        .collection(FirestoreConstants.colData)
        .doc(DateTimeHelper.toDayMonthId(dateTime));

    return ref.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data[FirestoreConstants.fieldFoodStats] != null) {
          return FoodStats.fromMap(Map<String, dynamic>.from(data[FirestoreConstants.fieldFoodStats]));
        }
      }
      return null;
    });
  }

  /// Watches all [FoodStats] documents for a specific [year].
  /// User in User History page
  Stream<List<FoodStatsEntry>> watchYearStats({required int year}) {
    final ref = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('$year')
        .collection(FirestoreConstants.colData)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodStatsEntry.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// One-time fetch all [FoodStats] documents for a specific [year].
  /// User in User History page
  Future<List<FoodStatsEntry>> getAllFoodStats({
    required int year,
  }) async {
    final ref = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc('$year')
        .collection(FirestoreConstants.colData)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true);

    final snapshot = await ref.get();

    return snapshot.docs.map((doc) {
      return FoodStatsEntry.fromMap(doc.id, doc.data());
    }).toList();
  }

  /// Permanently deletes the [FoodStats] document and its subcollections for a given date.
  Future<void> deleteFoodStats({required DateTime cardDateTime}) async {
    final docRef = _db
        .collection(FirestoreConstants.colUsers)
        .doc(_userId)
        .collection(FirestoreConstants.colHistory)
        .doc(cardDateTime.year.toString())
        .collection(FirestoreConstants.colData)
        .doc(DateTimeHelper.toDayMonthId(cardDateTime));

    final subColRef = docRef.collection(FirestoreConstants.colConsumedList);
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
