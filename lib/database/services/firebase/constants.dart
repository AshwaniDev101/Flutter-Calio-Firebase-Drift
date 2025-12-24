/// Centralized collection and field names for Firestore.
class FirestoreConstants {
  FirestoreConstants._();

  // Roots & User
  static const String colUsers = 'users';
  static const String colHistory = 'history';
  static const String colData = 'data';
  static const String colConsumedList = 'food_consumed_list';
  static const String colGlobalFoodList = 'food_list';

  // Field Names
  static const String fieldFoodStats = 'foodStats';
  static const String fieldCalories = 'calories';
  static const String fieldCount = 'count';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldLastUpdatedAt = 'lastUpdatedAt';
  static const String fieldVersion = 'version';
  static const String fieldName = 'name';
  static const String fieldTimestamp = 'timestamp';
}
