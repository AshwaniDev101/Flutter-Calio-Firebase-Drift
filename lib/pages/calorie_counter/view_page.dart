import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/calorie_counter_sliver_app_bar.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/food_list_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/search_bar_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/top_progress_sliver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_stats.dart';
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
    final theme = Theme.of(context);
    final vmCalorieCounter = context.watch<CalorieCounterViewModel>();
    
    final heatmap = context.select<CalorieHistoryViewModel, Map<String, FoodStats>>(
      (vm) => vm.heatmap
    );
    
    final vmHistory = context.read<CalorieHistoryViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            CalorieCounterSliverAppBar(viewModel: vmCalorieCounter),
            TopProgressSliver(viewModel: vmCalorieCounter),
            SliverToBoxAdapter(
              child: MonthHeatmapWidget(
                currentDateTime: vmCalorieCounter.pageDateTime,
                heatmapData: heatmap,
              ),
            ),
            MySearchBarSliver(viewModel: vmCalorieCounter),
            FoodListSliver(viewModel: vmCalorieCounter, historyViewModel: vmHistory),
          ],
        ),
      ),
    );
  }
}
