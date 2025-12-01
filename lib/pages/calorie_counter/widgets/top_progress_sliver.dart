
import 'package:flutter/material.dart';
import '../../../models/food_stats.dart';
import '../view_model.dart';
import 'calorie_bar_rounded.dart';


// TopProgressSliver shows the semicircle progress bar using a StreamBuilder
class TopProgressSliver extends StatelessWidget {
  final CalorieCounterViewModel viewModel;

  const TopProgressSliver({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StreamBuilder<FoodStats?>(
        stream: viewModel.watchConsumedFoodStats,
        builder: (context, snapshot) {
          final foodStats = snapshot.data ?? FoodStats.empty();
          return Padding(
            padding: const EdgeInsets.only(top: 14, left: 50, right: 50),
            child: CalorieSemicircleProgressBar(current: foodStats.calories),
          );
        },
      ),
    );
  }
}