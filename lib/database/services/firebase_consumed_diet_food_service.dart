import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/consumed_diet_food.dart';
import '../../models/food_stats.dart';

class FirebaseConsumedDietFoodService {
  FirebaseConsumedDietFoodService._();

  static final instance = FirebaseConsumedDietFoodService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  /// Watch consumed food list for a specific date, with debug logs
  Stream<List<ConsumedDietFood>> watchConsumedFood(DateTime date) {
    print('watchConsumedFood() started for ${date.day}-${date.month}-${date.year}');

    final path = '$_root/$_userId/history/${date.year}/data/${date.day}-${date.month}/food_consumed_list';
    print('Firestore path: $path');

    return _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${date.year}')
        .collection('data')
        .doc('${date.day}-${date.month}')
        .collection('food_consumed_list')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          print('🔥 Firestore snapshot error: $error');
        })
        .map((snapshot) {
          print('📡 Firestore emitted snapshot with ${snapshot.docs.length} docs');

          final List<ConsumedDietFood> list = [];

          for (final doc in snapshot.docs) {
            print('--- Raw doc: ${doc.id}, data: ${doc.data()}');

            try {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;

              final consumed = ConsumedDietFood.fromMap(data);
              list.add(consumed);

              print(
                '✅ Parsed ConsumedDietFood: id=${consumed.id}, '
                'name=${consumed.id}, count=${consumed.count}, '
                'timestamp=${consumed.timestamp}',
              );
            } catch (e, st) {
              print('❌ Error parsing doc ${doc.id}: $e');
              print(st);
            }
          }

          print('📦 Total parsed ConsumedDietFood items: ${list.length}');
          return list;
        });
  }

  /// Atomically changes the consumed count for a food item and updates the
  /// daily total statistics within a Firestore transaction.
  ///
  /// [count] represents the delta (e.g., +1 for adding, -1 for removing).
  /// This ensures that the daily summary is always consistent with the individual
  /// food counts.
  Future<void> changeConsumedFoodCount(double count, ConsumedDietFood food, DateTime dateTime) async {
    final dayDocRef = _db
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc('${dateTime.year}')
        .collection('data')
        .doc('${dateTime.day}-${dateTime.month}');
    // .collection('${dateTime.month}')
    // .doc('${dateTime.day}');

    final consumedFoodDocRef = dayDocRef.collection('food_consumed_list').doc(food.id);

    // Run as a transaction to ensure atomicity
    return _db.runTransaction((transaction) async {
      // 1. Get the current daily total stats
      final dailyStatsSnapshot = await transaction.get(dayDocRef);
      FoodStats currentStats;
      if (dailyStatsSnapshot.exists && dailyStatsSnapshot.data()?['foodStats'] != null) {
        currentStats = FoodStats.fromMap(dailyStatsSnapshot.data()!['foodStats']);
      } else {
        currentStats = FoodStats.empty();
      }

      // print("=== FoodStats currentStats: ${currentStats.toMap().toString()}");

      // 2. Calculate the change in stats based on the food's stats per serving and the count delta
      final statsDelta = FoodStats(
        calories: food.foodStats.calories * count,
        proteins: food.foodStats.proteins * count,
        carbohydrates: food.foodStats.carbohydrates * count,
        fats: food.foodStats.fats * count,
        minerals: food.foodStats.minerals * count,
        vitamins: food.foodStats.vitamins * count,
      );
      final FoodStats newTotalStats = currentStats.sum(statsDelta);

      // print("=== newTotalStats: ${newTotalStats.toMap().toString()}");

      // 3. Update the individual consumed food item's count
      final consumedFoodSnapshot = await transaction.get(consumedFoodDocRef);
      final foodMap = food.toMap()..remove('id');

      // print("=== foodMap: ${foodMap.toString()}");

      if (consumedFoodSnapshot.exists) {
        final double existingCount = consumedFoodSnapshot.data()?['count'] ?? 0;

        // print("=== existingCount: ${existingCount}");

        final newCount = existingCount + count;

        // print("=== newCount: ${newCount}");

        if (newCount > 0) {
          transaction.update(consumedFoodDocRef, {...foodMap, 'count': newCount});

          // print("===  transaction.update: ${foodMap.toString()},count newCount: ${newCount}");
        } else {
          // If count drops to 0 or below, remove the item from the consumed list

          transaction.delete(consumedFoodDocRef);
          // print("===   transaction.delete: ${consumedFoodDocRef.toString()}");
        }
      }
      // if (consumedFoodSnapshot.exists) {
      //   final existingCount = consumedFoodSnapshot.data()?['count'] ?? 0;
      //   final newCount = existingCount + count;
      //   transaction.update(consumedFoodDocRef, {
      //     ...foodMap,
      //     'count': newCount.clamp(0, double.infinity),
      //   });
      // }
      else if (count > 0) {
        // If the item wasn't in the list and we're adding it, create it
        transaction.set(consumedFoodDocRef, {...foodMap, 'count': count});

        // print("===   if (count > 0)  transaction.set  :  ${foodMap.toString()},count: ${count}");
      }

      // 4. Update the daily total stats document with the new aggregate
      transaction.set(dayDocRef, {
        // 'foodStats': newTotalStats.toMap()
        'foodStats': {'version': newTotalStats.version, 'calories': newTotalStats.calories},
      }, SetOptions(merge: true));

      // print("=== transaction.set  :  ${{'foodStats': newTotalStats.toMap()}.toString()}, SetOptions(merge: true)");

      // transaction.set(dayDocRef, {
      //   'foodStats': newTotalStats.toMap(),
      //   'timestamp': Timestamp.now(),
      // }, SetOptions(merge: true));
    });
  }
}
