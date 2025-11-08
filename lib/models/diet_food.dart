import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_stats.dart';

class DietFood {
  final int version;
  final String id;
  final String name;
  final Timestamp timestamp;
  final FoodStats foodStats;
  final double count;

  DietFood({
    this.version = 0,
    required this.id,
    required this.name,
    required this.timestamp,
    required this.foodStats,
    this.count = 0.0,
  });

  /// Creates a DietFood from an Available Food map
  factory DietFood.fromMap(Map<String, dynamic> map) {
    return DietFood(
      version: map['version'] ?? 0,
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      timestamp: map['timestamp'] as Timestamp,
      foodStats: FoodStats.fromMap(map['foodStats'] ?? {}),
      count: 0.0,
    );
  }

  /// Converts DietFood to map for storing available food
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'id': id,
      'name': name,
      'timestamp': timestamp, // store as Timestamp
      'foodStats': foodStats.toMap(),
      // no count field for available food
    };
  }



  /// Creates a copy of DietFood with optional overrides
  DietFood copyWith({
    int? version,
    String? id,
    String? name,
    Timestamp? timestamp,
    FoodStats? foodStats,
    double? count,
  }) {
    return DietFood(
      version: version ?? this.version,
      id: id ?? this.id,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      foodStats: foodStats ?? this.foodStats,
      count: count ?? this.count,
    );
  }




  factory DietFood.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['timestamp']);
    final timestamp = Timestamp.fromDate(date);

    return DietFood(
      version: json['version'] ?? 0,
      id: date.toIso8601String(), // use timestamp string as unique id
      name: json['name'] ?? '',
      timestamp: timestamp,
      foodStats: FoodStats.fromMap(json['foodStats'] ?? {}),
      count: 0.0,
    );
  }

}
