class FoodStats {
  final int version;
  final double proteins;
  final double carbohydrates;
  final double fats;
  final double vitamins;
  final double minerals;
  final double calories;

  const FoodStats({
    this.version = 0,
    required this.proteins,
    required this.carbohydrates,
    required this.fats,
    required this.vitamins,
    required this.minerals,
    required this.calories,
  });

  // A const constructor for an empty object
  const FoodStats.empty()
      : version = 0,
        proteins = 0.0,
        carbohydrates = 0.0,
        fats = 0.0,
        vitamins = 0.0,
        minerals = 0.0,
        calories = 0.0;

  /// Sum two FoodStats
  FoodStats sum(FoodStats other) {
    return FoodStats(
      version: version,
      proteins: proteins + other.proteins,
      carbohydrates: carbohydrates + other.carbohydrates,
      fats: fats + other.fats,
      vitamins: vitamins + other.vitamins,
      minerals: minerals + other.minerals,
      calories: calories + other.calories,
    );
  }

  /// Subtract another FoodStats from this
  FoodStats subtract(FoodStats other) {
    return FoodStats(
      version: version,
      proteins: proteins - other.proteins,
      carbohydrates: carbohydrates - other.carbohydrates,
      fats: fats - other.fats,
      vitamins: vitamins - other.vitamins,
      minerals: minerals - other.minerals,
      calories: calories - other.calories,
    );
  }

  /// Convert to map for Firestore, omitting fields with 0 value
  Map<String, dynamic> toMap() => {
        'version': version,
        if (proteins != 0) 'proteins': proteins,
        if (carbohydrates != 0) 'carbohydrates': carbohydrates,
        if (fats != 0) 'fats': fats,
        if (vitamins != 0) 'vitamins': vitamins,
        if (minerals != 0) 'minerals': minerals,
        if (calories != 0) 'calories': calories,
      };

  /// Factory constructor to create FoodStats from Firestore map
  factory FoodStats.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return 0.0; // default if null or wrong type
    }

    return FoodStats(
      version: map['version'] ?? 0,
      proteins: toDouble(map['proteins']),
      carbohydrates: toDouble(map['carbohydrates']),
      fats: toDouble(map['fats']),
      vitamins: toDouble(map['vitamins']),
      minerals: toDouble(map['minerals']),
      calories: toDouble(map['calories']),
    );
  }
}
