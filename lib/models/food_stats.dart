class FoodStats {
  final double proteins;
  final double carbohydrates;
  final double fats;
  final double vitamins;
  final double minerals;
  final double calories;

  FoodStats({
    required this.proteins,
    required this.carbohydrates,
    required this.fats,
    required this.vitamins,
    required this.minerals,
    required this.calories,
  });

  // A const constructor for an empty object is more idiomatic.
  const FoodStats.empty() : 
    proteins = 0.0,
    carbohydrates = 0.0,
    fats = 0.0,
    vitamins = 0.0,
    minerals = 0.0,
    calories = 0.0;


  FoodStats sum(FoodStats other) {
    return FoodStats(
      proteins: proteins + other.proteins,
      carbohydrates: carbohydrates + other.carbohydrates,
      fats: fats + other.fats,
      vitamins: vitamins + other.vitamins,
      minerals: minerals + other.minerals,
      calories: calories + other.calories,
    );
  }

  FoodStats subtract(FoodStats other) {
    return FoodStats(
      proteins: proteins - other.proteins,
      carbohydrates: carbohydrates - other.carbohydrates,
      fats: fats - other.fats,
      vitamins: vitamins - other.vitamins,
      minerals: minerals - other.minerals,
      calories: calories - other.calories,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'proteins': proteins,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'vitamins': vitamins,
      'minerals': minerals,
      'calories': calories,
    };
  }

  /// A factory constructor that can safely parse both int and double values from Firestore.
  factory FoodStats.fromMap(Map<String, dynamic> map) {
    // Helper to safely convert a num (int or double) to a double.
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return 0.0; // Default value if null or wrong type
    }

    return FoodStats(
      proteins: toDouble(map['proteins']),
      carbohydrates: toDouble(map['carbohydrates']),
      fats: toDouble(map['fats']),
      vitamins: toDouble(map['vitamins']),
      minerals: toDouble(map['minerals']),
      calories: toDouble(map['calories']),
    );
  }
}
