import 'package:flutter/cupertino.dart';

import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';
import '../manager/food_manager.dart';

class CalorieCounterViewModel extends ChangeNotifier {
  final DateTime pageDateTime;

  CalorieCounterViewModel({required this.pageDateTime});



  Stream<FoodStats?> get watchConsumedFoodStats => FoodManager.instance.watchConsumedFoodStats(pageDateTime);
  Stream<List<DietFood>> get watchMergedFoodList => FoodManager.instance.watchMergedFoodList(pageDateTime);


  void onQuantityChange(double oldValue, double newValue, DietFood food) {
    FoodManager.instance.changeConsumedCount(newValue - oldValue, food, pageDateTime);
  }




  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }



  // ===== CRUD OPERATIONS =====

  /// Adds a new [DietFood] item to the database
  /// and shows a confirmation snackbar.
  void addFood(DietFood food) {
    FoodManager.instance.addToAvailableFood(food);
  }

  /// Updates an existing [DietFood] entry in the database.
  void editFood(DietFood editedFood) {
    FoodManager.instance.updateAvailableFood(editedFood);
    // FoodHistoryRepository.instance.updateFoodStats(editedFood.foodStats, widgets.pageDateTime);
  }

  /// Removes a [DietFood] item from the database.
  void deleteFood(DietFood food) {
    FoodManager.instance.removeFromAvailableFood(food);

  }




}
