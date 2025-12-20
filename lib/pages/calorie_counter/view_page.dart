import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/calorie_counter_sliver_app_bar.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/food_list_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/search_bar_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/top_progress_sliver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/month_heatmap/month_heatmap_widget.dart';
import '../user_history/view_model.dart';

class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;
  final bool isOldPage;

  // Page-level widget that provides the ViewModel to the subtree.
  CalorieCounterPage({Key? key, required this.pageDateTime, this.isOldPage = false})
    : super(key: key ?? ValueKey(pageDateTime));

  @override
  Widget build(BuildContext context) {
    // Creates the ViewModel for the page.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CalorieCounterViewModel(pageDateTime: pageDateTime, isOldPage: isOldPage),
        ),
        ChangeNotifierProvider(
          create: (_) => CalorieHistoryViewModel(pageDateTime: pageDateTime)..loadMonthStats(),
        ),
      ],
      child: const _CalorieCounterPageBody(),
    );
  }
}

class _CalorieCounterPageBody extends StatelessWidget {
  const _CalorieCounterPageBody();

  @override
  Widget build(BuildContext context) {
    final vmCalorieCounter = context.watch<CalorieCounterViewModel>();
    final vmFoodStatsHistory = context.watch<CalorieHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar
            CalorieCounterSliverAppBar(viewModel: vmCalorieCounter),
            // Top semicircle progress
            TopProgressSliver(viewModel: vmCalorieCounter),
            // Heatmap
            SliverToBoxAdapter(
              child: MonthHeatmapWidget(currentDateTime: vmCalorieCounter.pageDateTime, heatmapData: vmFoodStatsHistory.heatmap),
            ),
            // Search bar
            MySearchBarSliver(viewModel: vmCalorieCounter),
            // Food list sliver
            FoodListSliver(viewModel: vmCalorieCounter, historyViewModel: vmFoodStatsHistory),
          ],
        ),
      ),
    );
  }
}
