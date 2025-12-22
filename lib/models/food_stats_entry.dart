import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_stats.dart';

class FoodStatsEntry {
  final String id;
  final FoodStats foodStats;
  final Timestamp timestamp;

  FoodStatsEntry({
    required this.id,
    required this.foodStats,
    required this.timestamp,
  });

  factory FoodStatsEntry.empty() {
    return FoodStatsEntry(
      id: 'empty',
      foodStats: const FoodStats.empty(),
      timestamp: Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodStats': foodStats.toMap(),
      'timestamp': timestamp,
    };
  }

  factory FoodStatsEntry.fromMap(String id, Map<String, dynamic> map) {
    return FoodStatsEntry(
      id: id,
      foodStats: FoodStats.fromMap(map['foodStats'] ?? {}),
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  DateTime getDateTime(int year) {
    final parts = id.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return DateTime(year, month, day);
  }
}
