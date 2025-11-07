import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/diet_food.dart';

class FirebaseGlobalDietFoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton
  FirebaseGlobalDietFoodService._();
  static final instance = FirebaseGlobalDietFoodService._();

  final String userId = 'user1'; // Make dynamic later

  /// Watch available food list
  Stream<List<DietFood>> watchGlobalFoodList() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DietFood.fromMap(data);
    }).toList());
  }

  /// Watch consumed food list for specific date
  Stream<List<DietFood>> watchConsumedFood(DateTime date) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('food_consumed_list')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      return DietFood.fromConsumedMap(data);
    }).toList());
  }





  /// Add food to available list
  Future<void> addGlobalFoodList(DietFood food) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(food.id);
    final map = food.toMap()..remove('id');
    return ref.set(map);
  }





  /// Delete food from available list
  Future<void> deleteFromGlobalFoodList(String id) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(id)
        .delete();
  }

  /// Update food in available list
  Future<void> updateInGlobalFoodListItem(String id, DietFood food) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }






}
