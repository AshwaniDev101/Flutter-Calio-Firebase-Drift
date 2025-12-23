class FoodStats {
  /// Schema version of this stats object.
  /// Increment when the structure changes.
  final int version;

  /// Total calories.
  final double calories;

  const FoodStats({
    this.version = 1,
    required this.calories,
  });

  /// Empty stats (zero calories)
  const FoodStats.empty()
      : version = 1,
        calories = 0.0;

  /// Adds two calorie stats together
  FoodStats sum(FoodStats other) {
    return FoodStats(
      version: version,
      calories: calories + other.calories,
    );
  }

  /// Subtracts another calorie stats from this
  FoodStats subtract(FoodStats other) {
    return FoodStats(
      version: version,
      calories: calories - other.calories,
    );
  }

  /// Converts this object to a Firestore-compatible map.
  /// Omits calories if the value is zero.
  Map<String, dynamic> toMap() => {
    'version': version,
    'calories': calories,
  };

  /// Creates a [FoodStats] object from a Firestore map.
  /// Missing or null values are treated as zero.
  factory FoodStats.fromMap(Map<String, dynamic> map) {
    return FoodStats(
      version: map['version'] ?? 1,
      calories: (map['calories'] ?? 0).toDouble(),
    );
  }
}
