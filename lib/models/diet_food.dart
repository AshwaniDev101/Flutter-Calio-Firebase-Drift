import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_stats.dart';

class DietFood {
  final String id;
  final String name;
  final Timestamp time;
  final FoodStats foodStats;
  final double count;

  DietFood({
    required this.id,
    required this.name,
    required this.time,
    required this.foodStats,
    this.count = 0.0, // default count for available food
  });

  /// Creates a DietFood from an Available Food map
  factory DietFood.fromAvailableMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      time: map['time'] as Timestamp,
      foodStats: FoodStats.fromMap(map['foodStats'] ?? {}),
      count: 0.0,
    );
  }

  /// Converts DietFood to map for storing available food
  Map<String, dynamic> toAvailableMap() {
    return {
      'id': id,
      'name': name,
      'time': time, // store as Timestamp
      'foodStats': foodStats.toMap(),
      // no count field for available food
    };
  }

  /// Creates a DietFood from a Consumed Food map
  factory DietFood.fromConsumedMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      time: map['time'] as Timestamp,
      foodStats: FoodStats.empty(),
      count: (map['count'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Converts DietFood to map for storing consumed food
  Map<String, dynamic> toConsumedMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'count': count,
    };
  }

  /// Creates a copy of DietFood with optional overrides
  DietFood copyWith({
    String? id,
    String? name,
    Timestamp? time,
    FoodStats? foodStats,
    double? count,
  }) {
    return DietFood(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      foodStats: foodStats ?? this.foodStats,
      count: count ?? this.count,
    );
  }
}
