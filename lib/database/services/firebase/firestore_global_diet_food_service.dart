import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants.dart';
import '../../../models/diet_food.dart';

/// A singleton service for managing the user's global list of available foods
/// in Cloud Firestore.
///
/// Data structure:
/// users/{userId}/globalFoodList/{foodId}
///
/// Provides real-time streaming and CRUD operations for [DietFood] items.
class FirestoreGlobalDietFoodService {
  FirestoreGlobalDietFoodService._();

  /// Singleton instance
  static final instance = FirestoreGlobalDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TODO: Make dynamic using FirebaseAuth.instance.currentUser?.uid
  final String userId = 'user1';

  /// Private collection reference for the user's global food list
  CollectionReference<Map<String, dynamic>> get _globalFoodCollection {
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(userId)
        .collection(FirestoreConstants.colGlobalFoodList);
  }

  /// Returns a real-time [Stream] of the user's global food list.
  ///
  /// Automatically updates when items are added, modified, or deleted.
  /// Returns an empty list if no foods exist yet.
  Stream<List<DietFood>> watchGlobalFoodList() {
    return _globalFoodCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return DietFood.fromMap(data);
      }).toList();
    });
  }

  /// Adds a new [DietFood] item to the global list.
  ///
  /// Uses the food's own [DietFood.id] as the document ID.
  Future<void> addGlobalFoodList(DietFood food) async {
    final map = food.toMap()..remove('id');
    await _globalFoodCollection.doc(food.id).set(map);
  }

  /// Deletes a [DietFood] item from the global list by its [id].
  Future<void> deleteFromGlobalFoodList(String id) async {
    await _globalFoodCollection.doc(id).delete();
  }

  /// Updates an existing [DietFood] item in the global list.
  ///
  /// Only updates the fields provided (partial update).
  Future<void> updateInGlobalFoodListItem(String id, DietFood food) async {
    final map = food.toMap()..remove('id');
    await _globalFoodCollection.doc(id).update(map);
  }

  /// Convenience upsert: adds the food if it doesn't exist, updates if it does.
  ///
  /// Useful for edit flows where you don't want to check existence first.
  Future<void> upsertGlobalFood(DietFood food) async {
    final map = food.toMap()..remove('id');
    await _globalFoodCollection.doc(food.id).set(map, SetOptions(merge: true));
  }
}