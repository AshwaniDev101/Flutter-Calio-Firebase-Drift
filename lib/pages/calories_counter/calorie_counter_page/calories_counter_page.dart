import 'dart:math';

import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_bar.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_bar_rounded.dart';
import 'package:calio/widget/new_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:calio/pages/calories_counter/calorie_counter_page/viewmodel/calorie_counter_view_model.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/food_quantity_selector.dart';

import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/edit_delete_option_menu.dart';
import '../calorie_history_page/calorie_history_page.dart';
import '../calorie_history_page/viewmodel/calorie_history_view_model.dart';
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

  AppBar _buildAppBar(BuildContext context) {

    final vm = context.watch<CalorieCounterViewModel>();

    return AppBar(
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

            switch (value) {
              case 'History':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChangeNotifierProvider(
                          create: (_) => CalorieHistoryViewModel(pageDateTime: vm.pageDateTime,),

                          child: CalorieHistoryPage(),
                        ),
                  ),
                );
                break;
              case 'Settings':

                break;
            }

          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'History', child: Text('History')),
            PopupMenuItem(value: 'Settings', child: Text('Settings')),
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

        SliverToBoxAdapter(
          child: StreamBuilder(

            stream: vm.watchConsumedFoodStats,
            builder: (context, snapshot){

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final foodStats = snapshot.data ?? FoodStats.empty();
              final caloriesCount = foodStats.calories;

              return Padding(
                padding: const EdgeInsets.only(top: 5,left: 50,right: 50),
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
        const SliverPadding(
          padding: EdgeInsets.all(12),
          sliver: SliverToBoxAdapter(child: _SearchBar()),
        ),


        // food list
        _FoodListSliver(viewModel: vm,),
      ],
    );
  }
}






class _SearchBar extends StatefulWidget {
  const _SearchBar({Key? key}) : super(key: key);

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
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    // Only unfocus when keyboard was open before and is now closed
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
            // height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              focusNode: _focusNode,
              onChanged: (value) => vm.updateSearchQuery = value,
              style: const TextStyle(fontSize: 12, height: 1.2),
              showCursor: false,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 14),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.amber.shade400, width: 1.2),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.add_circle, color: Colors.amber.shade700, size: 22),
            onPressed: () {
              DietFoodDialog.add(context, (DietFood food) => vm.addFood(food));
            },
            splashRadius: 20,
          ),
        )

        // NewButton(label: , onPressed: onPressed)
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shadowColor: barColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor.withValues(alpha: 0.9),Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [



              Container(
                width: 6,
                height: 70,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              Icon(Icons.apple,color: Colors.white,),
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
                            '${formatNumber(food.foodStats.calories)} kcal',
                            style: AppTextStyle.textStyleCardSubTitle.copyWith(color: Colors.grey[700]),
                          ),
                          if (food.count > 1)
                            Text(
                              ' (total: ${formatNumber(food.foodStats.calories * food.count)})',
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
                onChanged: (oldValue, newValue) => onQuantityChange(oldValue, newValue, food),
              ),
              const SizedBox(width: 6),
              editDeleteOptionMenu,
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );

  }
}


class _SemiCirclePainter extends CustomPainter {
  final double animatedFraction; // 0..1 how much of semicircle filled
  final double strokeWidth;
  final Color bgColor;
  final Color greenColor;
  final Color yellowColor;
  final Color redColor;
  final double greenPercent;
  final double yellowPercent;

  _SemiCirclePainter({
    required this.animatedFraction,
    required this.strokeWidth,
    required this.bgColor,
    required this.greenColor,
    required this.yellowColor,
    required this.redColor,
    required this.greenPercent,
    required this.yellowPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Semicircle occupies the full width and half the height.
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final startAngle = pi; // leftmost point
    final fullSweep = pi;  // 180 degrees

    // Draw background arc (full semicircle)
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, fullSweep, false, bgPaint);

    // Determine sweep for current progress
    final progressSweep = (fullSweep * animatedFraction).clamp(0.0, fullSweep);

    // Choose one color for the entire filled sweep based on thresholds
    final progressColor = (animatedFraction <= greenPercent)
        ? greenColor
        : (animatedFraction <= yellowPercent ? yellowColor : redColor);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
    // Use round cap for nicer ends. Use Butt if you want exact flush edges.
      ..strokeCap = StrokeCap.round;

    // Draw the single-color progress arc
    if (progressSweep > 0) {
      canvas.drawArc(rect, startAngle, progressSweep, false, progressPaint);
    }

    // draw thin separator ticks at thresholds (subtle)
    final tickPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 2;

    // compute sweeps for thresholds (where ticks live)
    final gSweep = fullSweep * greenPercent;
    final ySweep = fullSweep * yellowPercent;

    void drawTickAtSweep(double sweepOffset) {
      final angle = startAngle + sweepOffset;
      final inner = Offset(
        center.dx + (radius - strokeWidth / 2) * cos(angle),
        center.dy + (radius - strokeWidth / 2) * sin(angle),
      );
      final outer = Offset(
        center.dx + (radius + 6) * cos(angle),
        center.dy + (radius + 6) * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    drawTickAtSweep(gSweep.clamp(0.0, fullSweep));
    drawTickAtSweep(ySweep.clamp(0.0, fullSweep));
  }

  @override
  bool shouldRepaint(covariant _SemiCirclePainter old) {
    return old.animatedFraction != animatedFraction ||
        old.greenPercent != greenPercent ||
        old.yellowPercent != yellowPercent ||
        old.greenColor != greenColor ||
        old.yellowColor != yellowColor ||
        old.redColor != redColor ||
        old.bgColor != bgColor ||
        old.strokeWidth != strokeWidth;
  }
}
