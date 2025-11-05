import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:calio/pages/calories_counter/calorie_counter_page/viewmodel/calorie_counter_view_model.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/food_quantity_selector.dart';

import '../../../models/diet_food.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/edit_delete_option_menu.dart';
import '../helper/progress_visuals_helper.dart';
import 'new_diet_food/add_edit_diet_food_dialog.dart';


class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;

  CalorieCounterPage({Key? key, required this.pageDateTime})
      : super(key: key ?? ValueKey(pageDateTime));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalorieCounterViewModel(pageDateTime: pageDateTime),
      child: const _CalorieCounterPageBody(),
    );
  }
}

class _CalorieCounterPageBody extends StatelessWidget {
  const _CalorieCounterPageBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: const ScrollWithTopCard(),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.appbar,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    title: Text('Today', style: AppTextStyle.appBarTextStyle),
    actions: [
      IconButton(
        icon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
        onPressed: () {},
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
        onSelected: (value) {
          // handle menu actions if needed
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'Edit', child: Text('Edit')),
          PopupMenuItem(value: 'Delete', child: Text('Delete')),
        ],
      ),
    ],
  );
}

class ScrollWithTopCard extends StatelessWidget {
  const ScrollWithTopCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieCounterViewModel>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CalorieProgressBarDashboard(
            currentDateTime: vm.pageDateTime,
            stream: vm.watchConsumedFoodStats,
            onClickAdd: () => DietFoodDialog.add(context, (DietFood food) => vm.addFood(food)),
            onClickBack: () => Navigator.pop(context),
          ),
        ),

        // search bar
        const SliverPadding(
          padding: EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(child: _SearchBar()),
        ),

        // food list
        _FoodListSliver(viewModel: vm),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CalorieCounterViewModel>();

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search foods...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) => vm.updateSearchQuery = value,
    );
  }
}

class _FoodListSliver extends StatelessWidget {
  final CalorieCounterViewModel viewModel;

  const _FoodListSliver({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DietFood>>(
      stream: viewModel.watchMergedFoodList,
      builder: (context, snapshot) {
        final foods = snapshot.data ?? [];

        if (foods.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No foods added yet.'),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final food = foods[index];
              final barColor = AppColors.colorPalette[index % AppColors.colorPalette.length];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: _FoodCard(
                  key: ValueKey(food.id),
                  food: food,
                  barColor: barColor,
                  onQuantityChange: viewModel.onQuantityChange,
                  editDeleteOptionMenu: EditDeleteOptionMenu(
                    onEdit: () => DietFoodDialog.edit(context, food, (DietFood f) => viewModel.editFood(f)),
                    onDelete: () => viewModel.deleteFood(food),
                  ),
                ),
              );
            },
            childCount: foods.length,
          ),
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final DietFood food;
  final Color barColor;
  final Function(double oldValue, double newValue, DietFood dietFood) onQuantityChange;
  final EditDeleteOptionMenu editDeleteOptionMenu;

  const _FoodCard({
    super.key,
    required this.food,
    required this.barColor,
    required this.onQuantityChange,
    required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(width: 8, height: 64, color: barColor),

            // main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTextStyle.textStyleCardTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${formatNumber(food.foodStats.calories)} kcal', style: AppTextStyle.textStyleCardSubTitle),
                        if (food.count > 1)
                          Text(' (total:${formatNumber(food.foodStats.calories * food.count)})', style: AppTextStyle.textStyleCardSubTitle),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // actions
            editDeleteOptionMenu,

            FoodQuantitySelector(
              initialValue: food.count,
              onChanged: (oldValue, newValue) => onQuantityChange(oldValue, newValue, food),
            ),

            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
