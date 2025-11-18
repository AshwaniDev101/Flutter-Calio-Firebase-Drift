import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_stats.dart';
import '../../models/foodstats_entry.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie history data.
class FirebaseFoodStatsHistoryService {
  FirebaseFoodStatsHistoryService._();

  static final instance = FirebaseFoodStatsHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  /// Watches for real-time changes to the [FoodStats] for a specific [date].
  ///
  /// This method is pure and has no side-effects. It returns a stream
  /// that provides the latest [FoodStats] from Firestore or null if none exists.

  Stream<FoodStats?> watchFoodStatus(DateTime date) {
    final ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${date.year}')
        .collection('data')
        .doc('${date.day}-${date.month}');

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

  /// Retrieves all stored [FoodStats] documents for a specific [year] and [month].
  Future<List<FoodStatsEntry>> getFoodStatsForMonth({
    required int year,
    required int month,
  }) async {
    final ref = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('$year')
        .collection('data')
        .orderBy('timestamp', descending: true);

    final snapshot = await ref.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final stats = FoodStats.fromMap(Map<String, dynamic>.from(data['foodStats']));
      return FoodStatsEntry(doc.id, stats);
    }).toList();
  }

  // Future<Map<String, FoodStats>> getFoodStatsForMonth({required int year, required int month}) async {
  //   final monthRef = _db.collection(_root)
  //       .doc(_userId)
  //       .collection('history')
  //       .doc(year.toString())
  //       .collection('data')
  //       .orderBy('timestamp', descending: true);
  //   // .doc('${cardDateTime.day}-${cardDateTime.month}');
  //   // .collection(month.toString());
  //
  //   final snapshot = await monthRef.get();
  //
  //   final Map<String, FoodStats> statsMap = {};
  //
  //   for (final doc in snapshot.docs) {
  //     final data = doc.data();
  //
  //     statsMap[doc.id] = FoodStats.fromMap(data['foodStats']);
  //   }
  //
  //   // final reversedMap = Map.fromEntries(
  //   //     statsMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
  //   //   );
  //
  //   return statsMap;
  // }

  /// Permanently deletes the [FoodStats] document and its subcollections for a given date.
  Future<void> deleteFoodStats({required DateTime cardDateTime}) async {
    final docRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection('data')
        .doc('${cardDateTime.day}-${cardDateTime.month}');
    // .collection(cardDateTime.month.toString())
    // .doc(cardDateTime.day.toString());

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
