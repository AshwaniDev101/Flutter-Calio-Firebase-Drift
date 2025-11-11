
import 'package:calio/models/consumed_diet_food.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_bar_rounded.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/viewmodel/calorie_counter_view_model.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/food_quantity_selector.dart';
import '../../../core/helper.dart';
import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/edit_delete_option_menu.dart';
import '../calorie_history_page/calorie_history_page.dart';
import '../calorie_history_page/viewmodel/calorie_food_stats_history_view_model.dart';
import '../helper/progress_visuals_helper.dart';
import 'new_diet_food/add_edit_diet_food_dialog.dart';

class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;

  CalorieCounterPage({Key? key, required this.pageDateTime}) : super(key: key ?? ValueKey(pageDateTime));

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

  AppBar _buildAppBar(BuildContext context) {
    final vm = context.watch<CalorieCounterViewModel>();

    return AppBar(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          getTitle(vm),

        ],
      ),
      actions: [
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => CalorieFoodStatsHistoryViewModel(pageDateTime: vm.pageDateTime),
                      child: CalorieHistoryPage(),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: AppColors.appbarContent, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'History',
                      style: TextStyle(fontSize: 14, color: AppColors.appbarContent, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10,)
          ],
        ),

        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
        //   onSelected: (value) {
        //     switch (value) {
        //       case 'History':
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder:
        //                 (_) => ChangeNotifierProvider(
        //                   create: (_) => CalorieHistoryViewModel(pageDateTime: vm.pageDateTime),
        //
        //                   child: CalorieHistoryPage(),
        //                 ),
        //           ),
        //         );
        //         break;
        //       case 'Settings':
        //         break;
        //     }
        //   },
        //   itemBuilder:
        //       (_) => const [
        //         PopupMenuItem(value: 'History', child: Text('History')),
        //         PopupMenuItem(value: 'Settings', child: Text('Settings')),
        //       ],
        // ),
      ],
    );
  }

  Widget getTitle(CalorieCounterViewModel vm) {


    bool isToday = isSameDate(vm.pageDateTime, DateTime.now());

    String date = '${vm.pageDateTime.day}/${vm.pageDateTime.month}/${vm.pageDateTime.year}';

    String weekdayName = DateFormat('EEEE').format(vm.pageDateTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(isToday?'Today':date, style: AppTextStyle.appBarTextStyle),
      Text(isToday?date:'($weekdayName)', style: AppTextStyle.appBarTextStyle.copyWith(fontSize: 12,fontWeight: FontWeight.normal)),
    ],);
  }
}

class ScrollWithTopCard extends StatelessWidget {
  const ScrollWithTopCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieCounterViewModel>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StreamBuilder(
            stream: vm.watchConsumedFoodStats,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              final foodStats = snapshot.data ?? FoodStats.empty();
              final caloriesCount = foodStats.calories;

              return Padding(
                padding: const EdgeInsets.only(top: 5, left: 50, right: 50),
                child: CalorieSemicircle(
                  currentCalories: caloriesCount,
                  atLeastCalories: 1600,
                  atMostCalories: 2500,
                  // size: 300,
                  strokeWidth: 20,
                  // pulseDuration: Duration(seconds: 10),
                ),
              );
            },
          ),
        ),

        // SliverToBoxAdapter(
        //   child: CalorieProgressBarDashboard(
        //     currentDateTime: vm.pageDateTime,
        //     stream: vm.watchConsumedFoodStats,
        //     onClickAdd: () => DietFoodDialog.add(context, (DietFood food) => vm.addFood(food)),
        //     onClickBack: () => Navigator.pop(context),
        //   ),
        // ),

        // search bar
        const SliverPadding(padding: EdgeInsets.all(12), sliver: SliverToBoxAdapter(child: _SearchBar())),

        // food list
        _FoodListSliver(viewModel: vm),
      ],
    );
  }
}
class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  double _prevBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (_prevBottomInset > 0 && bottomInset == 0 && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _prevBottomInset = bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CalorieCounterViewModel>();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38, // keep it thin
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white, // clean background
              borderRadius: BorderRadius.circular(18), // rounded pill shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), // subtle shadow
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1), // subtle border like "New" button
            ),
            child: TextField(
              focusNode: _focusNode,
              onChanged: (value) => vm.updateSearchQuery = value,
              style: const TextStyle(fontSize: 12, height: 1.2),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        Row(
          children: [
            InkWell(
              onTap: () {
                DietFoodDialog.add(context, (DietFood food) => vm.addFood(food));
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 38, // same as search bar
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // clean modern look
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 1), // subtle border
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.appbarContent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'New',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.appbarContent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            SizedBox(width: 10,)
          ],
        ),

      ],
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

        // Apply search filter
        final filteredFoods = foods
            .where((food) => food.name.toLowerCase().contains(viewModel.searchQuery.toLowerCase()))
            .toList();

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

        if (filteredFoods.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No foods found.'),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final food = filteredFoods[index];
              final barColor = AppColors.colorPalette[index % AppColors.colorPalette.length];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: _FoodCard(
                  key: ValueKey(food.id),
                  food: food,
                  barColor: barColor,
                  onQuantityChange: viewModel.onQuantityChange,
                  editDeleteOptionMenu: EditDeleteOptionMenu(
                    onEdit: () => DietFoodDialog.edit(
                      context,
                      food,
                          (DietFood f) => viewModel.editFood(f),
                    ),
                    onDelete: () => viewModel.deleteFood(food),
                  ),
                ),
              );
            },
            childCount: filteredFoods.length, // ⚡ Use filtered list length
          ),
        );
      },
    );
  }
}


class _FoodCard extends StatelessWidget {
  final DietFood food;
  final Color barColor;
  final Function(double oldValue, double newValue, ConsumedDietFood consumedFood) onQuantityChange;
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
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      elevation: 2,
      color: Colors.white,
      shadowColor: barColor.withValues(alpha: 0.3),
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

            // Icon(Icons.apple,color: Colors.white,),
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
                        color: Colors.grey[800],
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
              onChanged: (oldValue, newValue) => onQuantityChange(oldValue, newValue, ConsumedDietFood.fromDietFood(food)),
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

