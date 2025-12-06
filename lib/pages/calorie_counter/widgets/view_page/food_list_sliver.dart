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

  const FoodListSliver({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
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

// Individual food card
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      elevation: 2,
      color: Colors.white,
      shadowColor: barColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 70,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTextStyle.textStyleCardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                        color: isDeleted ? Colors.red : Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${trimTrailingZero(food.foodStats.calories)} kcal',
                          style: AppTextStyle.textStyleCardSubTitle.copyWith(color: Colors.grey[700]),
                        ),
                        if (food.count > 1)
                          Text(
                            ' (total: ${trimTrailingZero(food.foodStats.calories * food.count)})',
                            style: AppTextStyle.textStyleCardSubTitle.copyWith(color: Colors.grey[600]),
                          ),
                      ],
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
            const SizedBox(width: 6),
            editDeleteOptionMenu,
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
