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
  DateTime _pageDateTime;
  final bool isOldPage;

  DateTime get pageDateTime => _pageDateTime;

  CalorieCounterViewModel({required DateTime pageDateTime, required this.isOldPage}) : _pageDateTime = pageDateTime {
    _initStreams();
  }

  late Stream<FoodStats?> watchCurrentDayDashboardFoodStats;
  late Stream<List<DietFood>> watchMergedFoodList;

  void _initStreams() {
    watchCurrentDayDashboardFoodStats = FoodManager.instance.watchCurrentDayDashboardFoodStats(_pageDateTime);
    watchMergedFoodList = FoodManager.instance.watchMergedFoodList(_pageDateTime);
  }

  void onQuantityChange(double oldValue, double newValue, ConsumedDietFood food) {
    FoodManager.instance.changeConsumedCount(newValue - oldValue, food, _pageDateTime);
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
    _pageDateTime = newDate;
    _initStreams(); // Re-initialize streams for the new date
    notifyListeners();
  }


}
