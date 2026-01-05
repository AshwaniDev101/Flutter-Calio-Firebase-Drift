import 'package:calio/pages/user_history/view_model.dart';
import 'package:calio/widgets/edit_delete_option_menu/edit_delete_option_menu.widget.dart';
import 'package:flutter/material.dart';

import '../../../../helper/progress_visuals_helper.dart';
import '../../../../models/consumed_diet_food.dart';
import '../../../../models/diet_food.dart';
import '../../../../theme/app_colors.dart';

import '../../add_new/add_edit_dialog.dart';
import '../../view_model.dart';
import '../micro_widgets/food_quantity_selector.dart';

// Food list sliver
// - Uses a stream from ViewModel and applies search filter
class FoodListSliver extends StatelessWidget {
  final CalorieCounterViewModel viewModel;
  final CalorieHistoryViewModel historyViewModel;

  const FoodListSliver({required this.viewModel, super.key, required this.historyViewModel});

  @override
  Widget build(BuildContext context) {
    // Removed historyViewModel.loadMonthStats() from build to avoid side effects.
    // The historyViewModel now manages its own stream.

    return StreamBuilder<List<DietFood>>(
      stream: viewModel.watchMergedFoodList,
      builder: (context, snapshot) {
        final foods = snapshot.data ?? [];

        if (foods.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No foods added yet.'))),
          );
        }

        final query = viewModel.searchQuery.toLowerCase();
        final filteredFoods = foods.where((f) => f.name.toLowerCase().contains(query)).toList();


        // Apply sorting based on current sort type
        filteredFoods.sort((a,b){

          return switch(viewModel.sortType)
          {
            SortType.aToB => a.name.compareTo(b.name),
            SortType.bToA => b.name.compareTo(a.name),
            SortType.calHighToLow => b.foodStats.calories.compareTo(a.foodStats.calories),
            SortType.calLowToLHigh => a.foodStats.calories.compareTo(b.foodStats.calories),
            SortType.consumed => b.count.compareTo(a.count),
          };
          return a.foodStats.calories.compareTo(b.foodStats.calories);


        });

        if (filteredFoods.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No foods found.'))),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final food = filteredFoods[index];
            final barColor = AppColors.colorPalette[index % AppColors.colorPalette.length];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: _FoodCard(
                key: ValueKey(food.id),
                food: food,
                barColor: barColor,
                onQuantityChange: viewModel.onQuantityChange,
                editDeleteOptionMenu: EditDeleteOptionMenuWidget(
                  onEdit: () => DietFoodDialog.edit(context, food, (DietFood f) => viewModel.editFood(f)),
                  onDelete: () => viewModel.deleteFood(food),
                ),
              ),
            );
          }, childCount: filteredFoods.length),
        );
      },
    );
  }
}

// Improved compact food card
class _FoodCard extends StatelessWidget {
  final DietFood food;
  final Color barColor;
  final Function(double oldValue, double newValue, ConsumedDietFood consumedFood) onQuantityChange;
  final EditDeleteOptionMenuWidget editDeleteOptionMenu;

  const _FoodCard({
    super.key,
    required this.food,
    required this.barColor,
    required this.onQuantityChange,
    required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = food.name == 'Deleted';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: barColor.withOpacity(0.2))],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 60,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: AppTextStyle.textStyleCardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: isDeleted ? TextDecoration.lineThrough : null,
                            color: isDeleted ? Colors.red : Colors.grey[850],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${trimTrailingZero(food.foodStats.calories)} kcal${food.count > 1 ? '  |  total ${trimTrailingZero(food.foodStats.calories * food.count)}' : ''}',
                    style: AppTextStyle.textStyleCardSubTitle.copyWith(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          FoodQuantitySelector(
            initialValue: food.count,
            onChanged:
                (oldValue, newValue) => onQuantityChange(oldValue, newValue, ConsumedDietFood.fromDietFood(food)),
          ),
          const SizedBox(width: 4),
          editDeleteOptionMenu,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
