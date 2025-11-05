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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 10),
            child: CalorieBar(currentCalories: 2500,atLeastCalories: 1600,atMostCalories: 2500,),
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
//   final int atLeastCalories; // 1600 kcal
//   final int atMostCalories;  // 2500 kcal
//
//   const CalorieBar({
//     super.key,
//     required this.currentCalories,
//     required this.atLeastCalories,
//     required this.atMostCalories,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final totalWidth = constraints.maxWidth;
//       final barHeight = 24.0;
//
//       // Segment thresholds
//       final greenPercent = 0.6; // 60%
//       final yellowPercent = 0.8; // 80%
//
//       // Compute filled width based on currentCalories
//       double filledWidth;
//       if (currentCalories <= atLeastCalories) {
//         filledWidth = totalWidth * (currentCalories / atLeastCalories * greenPercent);
//       } else if (currentCalories <= atMostCalories) {
//         filledWidth = totalWidth *
//             (greenPercent +
//                 (currentCalories - atLeastCalories) /
//                     (atMostCalories - atLeastCalories) *
//                     (yellowPercent - greenPercent));
//       } else {
//         // beyond atMostCalories
//         filledWidth = totalWidth *
//             (yellowPercent +
//                 (currentCalories - atMostCalories) /
//                     atMostCalories *
//                     (1.0 - yellowPercent));
//         if (filledWidth > totalWidth) filledWidth = totalWidth;
//       }
//
//       // Segment widths
//       final greenWidth = totalWidth * greenPercent;
//       final yellowWidth = totalWidth * (yellowPercent - greenPercent);
//       final redWidth = totalWidth * (1.0 - yellowPercent);
//
//       // Floating label position
//       final labelPosition = (filledWidth - 24 / 2).clamp(0.0, totalWidth - 32);
//
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Stack(
//             alignment: Alignment.centerLeft,
//             clipBehavior: Clip.none,
//             children: [
//               // Bar background
//               Container(
//                 height: barHeight,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Vertical markers
//                     Positioned(
//                         left: greenWidth - 1,
//                         top: 0,
//                         bottom: 0,
//                         child: Container(width: 2, color: Colors.grey.shade400)),
//                     Positioned(
//                         left: greenWidth + yellowWidth - 1,
//                         top: 0,
//                         bottom: 0,
//                         child: Container(width: 2, color: Colors.grey.shade400)),
//                     // Segments
//                     Positioned(
//                         left: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Container(
//                           width: filledWidth.clamp(0.0, greenWidth),
//                           color: Colors.greenAccent.shade200,
//                         )),
//                     if (filledWidth > greenWidth)
//                       Positioned(
//                           left: greenWidth,
//                           top: 0,
//                           bottom: 0,
//                           child: Container(
//                             width: (filledWidth - greenWidth).clamp(0.0, yellowWidth),
//                             color: Colors.yellowAccent.shade200,
//                           )),
//                     if (filledWidth > greenWidth + yellowWidth)
//                       Positioned(
//                           left: greenWidth + yellowWidth,
//                           top: 0,
//                           bottom: 0,
//                           child: Container(
//                             width: (filledWidth - greenWidth - yellowWidth)
//                                 .clamp(0.0, redWidth),
//                             color: Colors.redAccent.shade200,
//                           )),
//                   ],
//                 ),
//               ),
//
//
//               // Center(
//               //   child: Container(
//               //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//               //     decoration: BoxDecoration(
//               //       color: Colors.white,
//               //       borderRadius: BorderRadius.circular(4),
//               //       boxShadow: [
//               //         BoxShadow(
//               //           color: Colors.black26,
//               //           blurRadius: 2,
//               //           offset: Offset(0, 1),
//               //         )
//               //       ],
//               //     ),
//               //     child: Text(
//               //       "$currentCalories kcal",
//               //       style: const TextStyle(fontSize: 8),
//               //     ),
//               //   ),
//               // ),
//               // Floating label
//               Positioned(
//                 left: labelPosition-40,
//                 // top: 2, // above the bar
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 2,
//                           offset: Offset(0, 1),
//                         )
//                       ],
//                     ),
//                     child: Text(
//                       "$currentCalories kcal",
//                       style: const TextStyle(fontSize: 8,),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 4),
//
//           // Labels under markers
//           SizedBox(
//             height: 16,
//             width: totalWidth,
//             child: Stack(
//               children: [
//                 Positioned(
//                   left: greenWidth - 16,
//                   child: Text(
//                     "$atLeastCalories kcal",
//                     style: TextStyle(fontSize: 8, color: Colors.grey[700]),
//                   ),
//                 ),
//                 Positioned(
//                   left: greenWidth + yellowWidth - 16,
//                   child: Text(
//                     "$atMostCalories kcal",
//                     style: TextStyle(fontSize: 8, color: Colors.grey[700]),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }


class CalorieBar extends StatelessWidget {
  final int currentCalories;
  final int atLeastCalories; // green threshold
  final int atMostCalories; // yellow threshold
  final double greenPercent; // portion of bar reserved for "green"
  final double yellowPercent; // portion of bar reserved for "yellow"
  final double height;
  final bool showPercent;
  final Color bgColor;
  final Color greenColor;
  final Color yellowColor;
  final Color redColor;

  const CalorieBar({
    super.key,
    required this.currentCalories,
    required this.atLeastCalories,
    required this.atMostCalories,
    this.greenPercent = 0.6,
    this.yellowPercent = 0.8,
    this.height = 24.0,
    this.showPercent = true,
    this.bgColor = const Color(0xFFF0F0F0),
    this.greenColor = const Color(0xFF8CE99A),
    this.yellowColor = const Color(0xFFFFE082),
    this.redColor = const Color(0xFFFF8A80),
  })  : assert(greenPercent > 0 && greenPercent < yellowPercent && yellowPercent < 1.0),
        assert(atLeastCalories > 0 && atMostCalories > atLeastCalories);

  double _computeFraction() {
    final cur = currentCalories.toDouble();
    final atLeast = atLeastCalories.toDouble(); // green threshold
    final atMost = atMostCalories.toDouble();   // yellow threshold
    final g = greenPercent;                    // 60%
    final y = yellowPercent;                   // 80%

    if (cur <= atLeast) return (cur / atLeast) * g;
    if (cur <= atMost) {
      final t = (cur - atLeast) / (atMost - atLeast);
      return g + t * (y - g);
    }

    // Beyond atMost, extend proportionally to some maxCalories
    final maxCalories = atMost * 2; // for example, adjust as needed
    final t = ((cur - atMost) / (maxCalories - atMost)).clamp(0.0, 1.0);
    return y + t * (1.0 - y);
  }


  double displayedPercent() {
    final cur = currentCalories.toDouble();
    final atLeast = atLeastCalories.toDouble();
    final atMost = atMostCalories.toDouble();

    if (cur <= atMost) {
      // proportional to atMostCalories as 100%
      return (cur / atMost) * 100;
    }
    // beyond atMost, can scale beyond 100%
    return (cur / atMost) * 100;
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final fraction = _computeFraction().clamp(0.0, 1.0);

      // animate change in fraction smoothly when value changes
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: fraction),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, animatedFraction, _) {
          final filledWidth = animatedFraction * totalWidth;
          final greenW = totalWidth * greenPercent;
          final yellowW = totalWidth * (yellowPercent - greenPercent);
          final redW = totalWidth * (1.0 - yellowPercent);

          // fixed label width for simple clamping
          const labelW = 72.0;
          final labelLeft = (filledWidth - labelW / 2).clamp(0.0, totalWidth - labelW);

          // percent string
          // final percentText = (animatedFraction * 100).toStringAsFixed(0) + '%';
          final percentText = '${displayedPercent().toStringAsFixed(0)}%';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // background
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(height / 2),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),

                  // vertical markers
                  Positioned(
                    left: greenW - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey.shade400),
                  ),
                  Positioned(
                    left: greenW + yellowW - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey.shade400),
                  ),

                  // filled segments (clamped per segment)
                  // green segment
                  if (filledWidth > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: filledWidth.clamp(0.0, greenW),
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(height / 2)),
                        ),
                      ),
                    ),

                  // yellow segment
                  if (filledWidth > greenW)
                    Positioned(
                      left: greenW,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (filledWidth - greenW).clamp(0.0, yellowW),
                        color: yellowColor,
                      ),
                    ),

                  // red segment
                  if (filledWidth > greenW + yellowW)
                    Positioned(
                      left: greenW + yellowW,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (filledWidth - greenW - yellowW).clamp(0.0, redW),
                        decoration: BoxDecoration(
                          color: redColor,                     // move color here
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
                        ),
                      ),
                    ),


                  // floating label above bar
                  Positioned(
                    left: labelLeft,
                    top: -30,
                    child: Tooltip(
                      message: '$currentCalories kcal',
                      child: Container(
                        width: labelW,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currentCalories kcal',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (animatedFraction).clamp(0.0, 1.0),
                                child: Container(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // bottom row: thresholds and optional percent
              SizedBox(
                height: 18,
                width: totalWidth,
                child: Stack(
                  children: [
                    // atLeast label (centered approximately on marker)
                    Positioned(
                      left: (greenW - 40).clamp(0.0, totalWidth - 80),
                      child: Text(
                        '$atLeastCalories kcal',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),

                    // atMost label
                    Positioned(
                      left: (greenW + yellowW - 40).clamp(0.0, totalWidth - 80),
                      child: Text(
                        '$atMostCalories kcal',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),

                    if (showPercent)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Text(
                          percentText,
                          style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
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

    return Container(
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



            FoodQuantitySelector(
              initialValue: food.count,
              onChanged: (oldValue, newValue) => onQuantityChange(oldValue, newValue, food),
            ),

            const SizedBox(width: 8),
            // actions
            editDeleteOptionMenu,

            const SizedBox(width: 4),


            Container(width: 8, height: 64, color: barColor),
          ],
        ),
      ),
    );
  }
}
