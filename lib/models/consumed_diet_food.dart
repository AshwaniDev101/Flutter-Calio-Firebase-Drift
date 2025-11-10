import 'package:cloud_firestore/cloud_firestore.dart';
import 'diet_food.dart';
import 'food_stats.dart';

class ConsumedDietFood {
  final int version;
  final String id;
  final double calories;
  final double count;
  final Timestamp timestamp;
  final FoodStats foodStats;

  ConsumedDietFood({
    this.version = 0,
    required this.id,
    required this.calories,
    required this.count,
    required this.timestamp,
    required this.foodStats,
  });

  ConsumedDietFood copyWith({
    int? version,
    String? id,
    double? calories,
    double? count,
    Timestamp? timestamp,
    FoodStats? foodStats,
  }) {
    return ConsumedDietFood(
      version: version ?? this.version,
      id: id ?? this.id,
      calories: calories ?? this.calories,
      count: count ?? this.count,
      timestamp: timestamp ?? this.timestamp,
      foodStats: foodStats ?? this.foodStats,
    );
  }

  /// Creates a ConsumedDietFood from a map
  factory ConsumedDietFood.fromMap(Map<String, dynamic> map) {
    return ConsumedDietFood(
      version: map['version'] ?? 0,
      id: map['id'] ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      count: (map['count'] as num?)?.toDouble() ?? 1.0,
      timestamp: map['timestamp'] as Timestamp,
      foodStats: FoodStats.empty(), // Consumed food doesn't store stats
    );
  }
  

  /// Converts ConsumedDietFood to map for storage
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'id': id,
      'calories': calories,
      'timestamp': timestamp,
      'count': count,
    };
  }

  /// Creates a ConsumedDietFood from a DietFood object
  factory ConsumedDietFood.fromDietFood(DietFood food) {
    return ConsumedDietFood(
      version: food.version,
      id: food.id,
      calories: food.foodStats.calories,
      count: 0.0,
      timestamp: food.timestamp,
      foodStats: food.foodStats,
    );
  }
  
  
  
}
