
import 'package:flutter/material.dart';
import '../../../models/food_stats.dart';
import '../view_model.dart';
import 'calorie_bar_linear.dart';
import 'calorie_bar_rounded.dart';


class TopProgressSliver extends StatelessWidget {
  final CalorieCounterViewModel viewModel;

  const TopProgressSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TopProgressHeaderDelegate(
        viewModel: viewModel,
        minExtent: 115,   // pinned height
        maxExtent: 220,   // expanded height
      ),
    );
  }
}

class _TopProgressHeaderDelegate extends SliverPersistentHeaderDelegate {
  final CalorieCounterViewModel viewModel;

  @override
  final double minExtent;

  @override
  final double maxExtent;

  _TopProgressHeaderDelegate({
    required this.viewModel,
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > (maxExtent - minExtent) * 0.6;

    return SizedBox.expand(
      child: Material(
        color: Colors.grey[100],
        child: isPinned
            ? _buildLinearProgress(context)
            : _buildExpandedProgress(context),
      ),
    );
  }

  Widget _buildLinearProgress(BuildContext context) {
    return StreamBuilder<FoodStats?>(
      stream: viewModel.watchConsumedFoodStats,
      builder: (context, snapshot) {
        final foodStats = snapshot.data ?? FoodStats.empty();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CalorieLinearProgressBar(current: foodStats.calories),
        );
      },
    );
  }


    Widget _buildExpandedProgress(BuildContext context) {
    return StreamBuilder<FoodStats?>(
      stream: viewModel.watchConsumedFoodStats,
      builder: (context, snapshot) {
        final foodStats = snapshot.data ?? FoodStats.empty();
        return Padding(
          padding: const EdgeInsets.only(top: 14, left: 50, right: 50),
          child: CalorieSemicircleProgressBar(current: foodStats.calories),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _TopProgressHeaderDelegate oldDelegate) => true;
}
