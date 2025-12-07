import 'package:calio/models/food_stats.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/caution_label/caution_label_widget.dart';

class WeeklyListWidget extends StatelessWidget {
  const WeeklyListWidget({super.key});

  final bool isPerfect = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [

                Container(
                  width: 6,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.colorPalette[index % AppColors.colorPalette.length],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                  ),
                ),

                Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black.withValues(alpha: 0.05))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Week ${index + 11}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 2),
                      // SizedBox(
                      //   width: 50,
                      //     child: CationLabelWidget(foodStats: FoodStats.empty(),)),
                      getLabel(),
                      //
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getLabel() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${12000}", style: TextStyle(fontSize:16 ,color: Colors.green[400], fontWeight: FontWeight.w800)),
        Text(" kcal", style: TextStyle(fontSize:12 ,color: Colors.green[400], fontWeight: FontWeight.bold)),
      ],
    );
    // return Container(
    //   width: 74,
    //   height: 18,
    //   // decoration: BoxDecoration(color: Colors.green[400], borderRadius: BorderRadius.circular(20)),
    //   child: Center(child: Text("${12000} kcal", style: TextStyle(fontSize:12 ,color: Colors.green[400], fontWeight: FontWeight.bold))),
    // );
  }
}
