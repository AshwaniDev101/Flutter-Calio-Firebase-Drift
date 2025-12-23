import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_stats.dart';

class FoodStatsEntry {
  final String id;
  final FoodStats foodStats;
  final Timestamp createdAt;
  final Timestamp lastUpdatedAt;

  FoodStatsEntry({
    required this.id,
    required this.foodStats,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory FoodStatsEntry.empty() {
    return FoodStatsEntry(
      id: 'empty',
      foodStats: const FoodStats.empty(),
      createdAt: Timestamp.now(),
      lastUpdatedAt: Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodStats': foodStats.toMap(),
      'createdAt': createdAt,
      'lastUpdatedAt': lastUpdatedAt,
    };
  }

  factory FoodStatsEntry.fromMap(String id, Map<String, dynamic> map) {
    return FoodStatsEntry(
      id: id,
      foodStats: FoodStats.fromMap(map['foodStats'] ?? {}),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastUpdatedAt: map['lastUpdatedAt'] ?? Timestamp.now(),
    );
  }
}
