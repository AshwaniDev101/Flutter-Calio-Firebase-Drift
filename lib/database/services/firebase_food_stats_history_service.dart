import 'package:calio/core/helpers/date_time_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_stats.dart';
import '../../models/food_stats_entry.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie history data.
class FirebaseFoodStatsHistoryService {
  FirebaseFoodStatsHistoryService._();

  static final instance = FirebaseFoodStatsHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  /// Gives Dashboard data for current day
  /// Stream of [FoodStats] for a specific date.
  Stream<FoodStats?> watchCurrentDayDashboardFoodStats(DateTime dateTime) {
    final ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        .doc(DateTimeHelper.toDayMonthId(dateTime));

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

  /// Watches all [FoodStats] documents for a specific [year].
  /// User in User History page
  Stream<List<FoodStatsEntry>> watchYearStats({required int year}) {
    final ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('$year')
        .collection('data')
        .orderBy('createdAt', descending: true);

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
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('$year')
        .collection('data')
        .orderBy('createdAt', descending: true);

    final snapshot = await ref.get();

    return snapshot.docs.map((doc) {
      return FoodStatsEntry.fromMap(doc.id, doc.data());
    }).toList();
  }

  /// Permanently deletes the [FoodStats] document and its subcollections for a given date.
  Future<void> deleteFoodStats({required DateTime cardDateTime}) async {
    final docRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection('data')
        .doc(DateTimeHelper.toDayMonthId(cardDateTime));

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
