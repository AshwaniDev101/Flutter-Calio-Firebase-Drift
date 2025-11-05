import 'package:calio/pages/calories_counter/calorie_counter_page/viewmodel/calorie_counter_view_model.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/food_quantity_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/helper.dart';
import '../../../models/diet_food.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/edit_delete_option_menu.dart';
import 'new_diet_food/add_edit_diet_food_dialog.dart';


class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;

  CalorieCounterPage({Key? key, required this.pageDateTime}) : super(key: key ?? ValueKey(pageDateTime));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalorieCounterViewModel(pageDateTime: pageDateTime),
      child: _CaloriesCounterPageBody(),
    );
  }
}

class _CaloriesCounterPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieCounterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: _getAppBar(context),

      body: ScrollWithTopCard(),
    );
  }

  AppBar _getAppBar(context) {
    return AppBar(
      backgroundColor: AppColors.appbar,
      // elevation: 2, // subtle shadow if you want it to stand out
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text('Today', style: AppTextStyle.appBarTextStyle),

      // left icon
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
        onPressed: () {
          Navigator.pop(context); // or custom logic
        },
      ),

      // right-side actions (3-dot menu, icons, etc.)
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
          onPressed: () {
            // search logic
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
          onSelected: (value) {
            if (value == 'Edit') {
              // handle edit
            } else if (value == 'Delete') {
              // handle delete
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
            const PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }
}



class ScrollWithTopCard extends StatelessWidget {
  const ScrollWithTopCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieCounterViewModel>();

    return CustomScrollView(
      slivers: [
        // Progress Dashboard
        SliverToBoxAdapter(
          child: CalorieProgressBarDashboard(
            currentDateTime: vm.pageDateTime,
            stream: vm.watchConsumedFoodStats,
            onClickAdd: () => DietFoodDialog.add(context, (DietFood food) {
              vm.addFood(food);
            }),
            onClickBack: () => Navigator.pop(context),
          ),
        ),

        // Search bar
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(
            child: TextField(
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
            ),
          ),
        ),

        // Food List (converted into sliver)
        StreamBuilder<List<DietFood>>(
          stream: vm.watchMergedFoodList,
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                    child: _FoodCard(
                      key: ValueKey(food.id),
                      food: food,
                      barColor: barColor,
                      onQuantityChange: vm.onQuantityChange,
                      editDeleteOptionMenu: EditDeleteOptionMenu(
                        onEdit: () => DietFoodDialog.edit(
                                    context,
                                    food,
                                    (DietFood food) => vm.editFood(food),
                                  ),
                          onDelete: () {
                            vm.deleteFood(food);
                          }),



                    )

                  );
                },
                childCount: foods.length,
              ),
            );
          },
        ),
      ],
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
    required this.onQuantityChange, required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {



    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // colored bar
              Container(width: 8, height: 64, color: barColor),
              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        // style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                        style: AppTextStyle.textStyleCardTitle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${formatNumber(food.foodStats.calories)} kcal',
                            // style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            style: AppTextStyle.textStyleCardSubTitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (food.count > 1)
                            Text(
                              ' (total:${formatNumber(food.foodStats.calories * food.count)})',
                              // style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              style: AppTextStyle.textStyleCardSubTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


              editDeleteOptionMenu,

              FoodQuantitySelector(
                initialValue: food.count,
                onChanged: (oldValue, newValue) {
                  onQuantityChange(oldValue, newValue, food);
                },
              ),

              SizedBox(
                width: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
