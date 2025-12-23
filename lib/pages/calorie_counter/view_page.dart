import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/calorie_counter_sliver_app_bar.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/food_list_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/search_bar_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/top_progress_sliver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_stats.dart';
import '../../theme/app_colors.dart';
import '../../widgets/month_heatmap/month_heatmap_widget.dart';
import '../user_history/view_model.dart';

class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;
  final bool isOldPage;

  CalorieCounterPage({Key? key, required this.pageDateTime, this.isOldPage = false})
      : super(key: key ?? ValueKey(pageDateTime));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalorieCounterViewModel(pageDateTime: pageDateTime, isOldPage: isOldPage),
      child: const _CalorieCounterPageBody(),
    );
  }
}

class _CalorieCounterPageBody extends StatelessWidget {
  const _CalorieCounterPageBody();

  @override
  Widget build(BuildContext context) {
    final vmCalorieCounter = context.watch<CalorieCounterViewModel>();
    
    // Select only the heatmap data to minimize rebuilds
    final heatmap = context.select<CalorieHistoryViewModel, Map<String, FoodStats>>(
      (vm) => vm.heatmap
    );
    
    // Get a reference to history without subscribing to everything
    final vmHistory = context.read<CalorieHistoryViewModel>();

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
              child: MonthHeatmapWidget(
                currentDateTime: vmCalorieCounter.pageDateTime,
                heatmapData: heatmap,
              ),
            ),
            // Search bar
            MySearchBarSliver(viewModel: vmCalorieCounter),
            // Food list sliver
            FoodListSliver(viewModel: vmCalorieCounter, historyViewModel: vmHistory),
          ],
        ),
      ),
    );
  }
}
