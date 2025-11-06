import 'dart:math';

import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_bar.dart';
import 'package:calio/pages/calories_counter/calorie_counter_page/widgets/calorie_bar_rounded.dart';
import 'package:calio/widget/new_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:calio/pages/calories_counter/calorie_counter_page/viewmodel/calorie_counter_view_model.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 10),
            // child: CalorieBar(currentCalories: 4000,atLeastCalories: 1600,atMostCalories: 2500,),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CalorieSemicircle(
                currentCalories: 1700,
                atLeastCalories: 1600,
                atMostCalories: 2500,
                size: 260,
                strokeWidth: 20,
                // pulseDuration: Duration(seconds: 10),
              )
            )

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


        // SliverToBoxAdapter(
        //   child:Row(
        //     mainAxisAlignment:MainAxisAlignment.end,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Icon(Icons.sort_by_alpha,size: 16,color: AppColors.appbarContent,),
        //       SizedBox(
        //         width: 20,
        //       )
        //     ],
        //   ),
        // ),


        // food list
        _FoodListSliver(viewModel: vm,),
      ],
    );
  }
}




// class CalorieBar extends StatelessWidget {
//   final int currentCalories;
//   final int atLeastCalories; // green threshold
//   final int atMostCalories; // yellow threshold
//   final double greenPercent; // portion of bar reserved for "green"
//   final double yellowPercent; // portion of bar reserved for "yellow"
//   final double height;
//   final bool showPercent;
//   final Color bgColor;
//   final Color greenColor;
//   final Color yellowColor;
//   final Color redColor;
//
//   const CalorieBar({
//     super.key,
//     required this.currentCalories,
//     required this.atLeastCalories,
//     required this.atMostCalories,
//     this.greenPercent = 0.6,
//     this.yellowPercent = 0.8,
//     this.height = 24.0,
//     this.showPercent = true,
//     this.bgColor = const Color(0xFFF0F0F0),
//     this.greenColor = const Color(0xFF8CE99A),
//     this.yellowColor = const Color(0xFFFFE082),
//     this.redColor = const Color(0xFFFF8A80),
//   })  : assert(greenPercent > 0 && greenPercent < yellowPercent && yellowPercent < 1.0),
//         assert(atLeastCalories > 0 && atMostCalories > atLeastCalories);
//
//   double _computeFraction() {
//     final cur = currentCalories.toDouble();
//     final atLeast = atLeastCalories.toDouble(); // green threshold
//     final atMost = atMostCalories.toDouble();   // yellow threshold
//     final g = greenPercent;                    // 60%
//     final y = yellowPercent;                   // 80%
//
//     if (cur <= atLeast) return (cur / atLeast) * g;
//     if (cur <= atMost) {
//       final t = (cur - atLeast) / (atMost - atLeast);
//       return g + t * (y - g);
//     }
//
//     // Beyond atMost, extend proportionally to some maxCalories
//     final maxCalories = atMost * 2; // for example, adjust as needed
//     final t = ((cur - atMost) / (maxCalories - atMost)).clamp(0.0, 1.0);
//     return y + t * (1.0 - y);
//   }
//
//
//   double displayedPercent() {
//     final cur = currentCalories.toDouble();
//     final atLeast = atLeastCalories.toDouble();
//     final atMost = atMostCalories.toDouble();
//
//     if (cur <= atMost) {
//       // proportional to atMostCalories as 100%
//       return (cur / atMost) * 100;
//     }
//     // beyond atMost, can scale beyond 100%
//     return (cur / atMost) * 100;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final totalWidth = constraints.maxWidth;
//       final fraction = _computeFraction().clamp(0.0, 1.0);
//
//       // animate change in fraction smoothly when value changes
//       return TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: fraction),
//         duration: const Duration(milliseconds: 420),
//         curve: Curves.easeOutCubic,
//         builder: (context, animatedFraction, _) {
//           final filledWidth = animatedFraction * totalWidth;
//           final greenW = totalWidth * greenPercent;
//           final yellowW = totalWidth * (yellowPercent - greenPercent);
//           final redW = totalWidth * (1.0 - yellowPercent);
//
//           // fixed label width for simple clamping
//           const labelW = 72.0;
//           final labelLeft = (filledWidth - labelW / 2).clamp(0.0, totalWidth - labelW);
//
//           // percent string
//           // final percentText = (animatedFraction * 100).toStringAsFixed(0) + '%';
//           final percentText = '${displayedPercent().toStringAsFixed(0)}%';
//
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   // background
//                   Container(
//                     height: height,
//                     decoration: BoxDecoration(
//                       color: bgColor,
//                       borderRadius: BorderRadius.circular(height / 2),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                   ),
//
//                   // vertical markers
//                   Positioned(
//                     left: greenW - 1,
//                     top: 0,
//                     bottom: 0,
//                     child: Container(width: 2, color: Colors.grey.shade400),
//                   ),
//                   Positioned(
//                     left: greenW + yellowW - 1,
//                     top: 0,
//                     bottom: 0,
//                     child: Container(width: 2, color: Colors.grey.shade400),
//                   ),
//
//                   // filled segments (clamped per segment)
//                   // green segment
//                   if (filledWidth > 0)
//                     Positioned(
//                       left: 0,
//                       top: 0,
//                       bottom: 0,
//                       child: Container(
//                         width: filledWidth.clamp(0.0, greenW),
//                         decoration: BoxDecoration(
//                           color: greenColor,
//                           borderRadius: BorderRadius.horizontal(left: Radius.circular(height / 2)),
//                         ),
//                       ),
//                     ),
//
//                   // yellow segment
//                   if (filledWidth > greenW)
//                     Positioned(
//                       left: greenW,
//                       top: 0,
//                       bottom: 0,
//                       child: Container(
//                         width: (filledWidth - greenW).clamp(0.0, yellowW),
//                         color: yellowColor,
//                       ),
//                     ),
//
//                   // red segment
//                   if (filledWidth > greenW + yellowW)
//                     Positioned(
//                       left: greenW + yellowW,
//                       top: 0,
//                       bottom: 0,
//                       child: Container(
//                         width: (filledWidth - greenW - yellowW).clamp(0.0, redW),
//                         decoration: BoxDecoration(
//                           color: redColor,                     // move color here
//                           borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
//                         ),
//                       ),
//                     ),
//
//
//                   // floating label above bar
//                   Positioned(
//                     left: labelLeft,
//                     top: -30,
//                     child: Tooltip(
//                       message: '$currentCalories kcal',
//                       child: Container(
//                         width: labelW,
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(6),
//                           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               '$currentCalories kcal',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//                             ),
//                             const SizedBox(height: 2),
//                             Container(
//                               height: 4,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                               child: FractionallySizedBox(
//                                 alignment: Alignment.centerLeft,
//                                 widthFactor: (animatedFraction).clamp(0.0, 1.0),
//                                 child: Container(color: Colors.grey.shade300),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 6),
//
//               // bottom row: thresholds and optional percent
//               SizedBox(
//                 height: 18,
//                 width: totalWidth,
//                 child: Stack(
//                   children: [
//                     // atLeast label (centered approximately on marker)
//                     Positioned(
//                       left: (greenW - 40).clamp(0.0, totalWidth - 80),
//                       child: Text(
//                         '$atLeastCalories kcal',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[700]),
//                       ),
//                     ),
//
//                     // atMost label
//                     Positioned(
//                       left: (greenW + yellowW - 40).clamp(0.0, totalWidth - 80),
//                       child: Text(
//                         '$atMostCalories kcal',
//                         style: TextStyle(fontSize: 10, color: Colors.grey[700]),
//                       ),
//                     ),
//
//                     if (showPercent)
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Text(
//                           percentText,
//                           style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
// }

















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
            onPressed: () {},
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
