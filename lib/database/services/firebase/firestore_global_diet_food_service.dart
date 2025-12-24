import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import '../../../models/diet_food.dart';

/// A service for managing the global list of foods available to a user.
class FirestoreGlobalDietFoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton
  FirestoreGlobalDietFoodService._();
  static final instance = FirestoreGlobalDietFoodService._();

  final String userId = 'user1'; // Make dynamic later

  /// Returns a real-time [Stream] of the user's global food list.
  Stream<List<DietFood>> watchGlobalFoodList() {
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(userId)
        .collection(FirestoreConstants.colGlobalFoodList)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return DietFood.fromMap(data);
            }).toList());
  }

  /// Adds a new [DietFood] item to the global list.
  Future<void> addGlobalFoodList(DietFood food) {
    final ref = _db
        .collection(FirestoreConstants.colUsers)
        .doc(userId)
        .collection(FirestoreConstants.colGlobalFoodList)
        .doc(food.id);
    final map = food.toMap()..remove('id');
    return ref.set(map);
  }

  /// Deletes a [DietFood] item from the global list by its [id].
  Future<void> deleteFromGlobalFoodList(String id) {
    return _db
        .collection(FirestoreConstants.colUsers)
        .doc(userId)
        .collection(FirestoreConstants.colGlobalFoodList)
        .doc(id)
        .delete();
  }

  /// Updates an existing [DietFood] item in the global list.
  Future<void> updateInGlobalFoodListItem(String id, DietFood food) {
    final ref = _db
        .collection(FirestoreConstants.colUsers)
        .doc(userId)
        .collection(FirestoreConstants.colGlobalFoodList)
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }
}
