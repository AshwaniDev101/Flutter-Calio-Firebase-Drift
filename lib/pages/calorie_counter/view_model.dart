import 'package:calio/models/consumed_diet_food.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';
import 'manager/food_manager.dart';


enum SortType {
  aToB,
  bToA,
  calHighToLow,
  calLowToLHigh,
  consumed,
}

class CalorieCounterViewModel extends ChangeNotifier {
  DateTime pageDateTime;
  final bool isOldPage;

  CalorieCounterViewModel({required this.pageDateTime, required this.isOldPage});

  // Gives Dashboard data for current day (FoodStats of the day)
  Stream<FoodStats?> get watchCurrentDayDashboardFoodStats => FoodManager.instance.watchCurrentDayDashboardFoodStats(pageDateTime);

  Stream<List<DietFood>> get watchMergedFoodList => FoodManager.instance.watchMergedFoodList(pageDateTime);

  void onQuantityChange(double oldValue, double newValue, ConsumedDietFood food) {
    FoodManager.instance.changeConsumedCount(newValue - oldValue, food, pageDateTime);
  }


  SortType _sortType = SortType.aToB;

  SortType get sortType => _sortType;

  set updateSortType(SortType sortType) {
    _sortType = sortType;
    Log.i('Sort type updated to: $_sortType');
    notifyListeners(); // Triggers rebuilds in listening widgets
  }


  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  set updateSearchQuery(String query) {
    _searchQuery = query;

    Log.i('query: $_searchQuery');
    notifyListeners();
  }

  // ===== CRUD OPERATIONS =====

  /// Adds a new [DietFood] item to the database
  /// and shows a confirmation snack bar.
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

  void updatePageDateTime(DateTime newDate) {
    pageDateTime = newDate;
    notifyListeners();
  }


}
