import 'package:calio/models/food_stats.dart';
import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:calio/pages/calorie_counter/widgets/calorie_bar/calorie_bar_rounded.dart';
import 'package:calio/pages/calorie_counter/widgets/micro_widgets/calorie_appbar_title.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/calorie_counter_sliver_app_bar.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/food_list_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/search_bar_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/view_page/top_progress_sliver.dart';
import 'package:calio/pages/user_history/view_model.dart';
import 'package:calio/pages/user_history/view_page.dart';
import 'package:calio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/month_heatmap/month_heatmap_widget.dart';

/// Main page for viewing and editing daily calorie/food intake.
class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;
  final bool isOldPage;

  const CalorieCounterPage({
    super.key,
    required this.pageDateTime,
    this.isOldPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalorieCounterViewModel(
        pageDateTime: pageDateTime,
        isOldPage: isOldPage,
      ),
      child: const _CalorieCounterPageBody(),
    );
  }
}

class _CalorieCounterPageBody extends StatelessWidget {
  const _CalorieCounterPageBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<CalorieCounterViewModel>();

    // Efficiently select only the heatmap data
    final heatmapData = context.select<CalorieHistoryViewModel, Map<String, FoodStats>>(
      (historyVm) => historyVm.heatmap,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Removed extendBodyBehindAppBar: true to prevent content from going under the status/app bar
      body: SafeArea(
        // top: true by default, handles notches and status bars correctly
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return _buildWideLayout(context, vm, heatmapData);
              } else {
                return _buildMobileLayout(context, vm, heatmapData);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, 
    CalorieCounterViewModel vm, 
    Map<String, FoodStats> heatmap
  ) {
    return CustomScrollView(
      slivers: [
        CalorieCounterSliverAppBar(viewModel: vm),
        TopProgressSliver(viewModel: vm),
        SliverToBoxAdapter(
          child: MonthHeatmapWidget(
            currentDateTime: vm.pageDateTime,
            heatmapData: heatmap,
          ),
        ),
        MySearchBarSliver(viewModel: vm),
        FoodListSliver(
          viewModel: vm,
          historyViewModel: context.read<CalorieHistoryViewModel>(),
        ),
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context, 
    CalorieCounterViewModel vm, 
    Map<String, FoodStats> heatmap
  ) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.appbar,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: CalorieAppBarTitle(
            date: vm.pageDateTime, 
            onDateSelected: vm.updatePageDateTime
          ),
          actions: vm.isOldPage ? [] : [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalorieHistoryPage()),
                  );
                },
                icon: Icon(Icons.calendar_month_rounded, color: AppColors.appbarContent),
                label: Text('History', style: TextStyle(color: AppColors.appbarContent)),
              ),
            )
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT SIDE: Progress & Heatmap
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      StreamBuilder<FoodStats?>(
                        stream: vm.watchCurrentDayDashboardFoodStats,
                        builder: (context, snapshot) {
                          final foodStats = snapshot.data ?? FoodStats.empty();
                          return CalorieSemicircleProgressBarWidget(
                            current: foodStats.calories,
                            size: 240,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      MonthHeatmapWidget(
                        currentDateTime: vm.pageDateTime,
                        heatmapData: heatmap,
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT SIDE: Search & Food List
              Expanded(
                flex: 3,
                child: CustomScrollView(
                  slivers: [
                    MySearchBarSliver(viewModel: vm),
                    FoodListSliver(
                      viewModel: vm, 
                      historyViewModel: context.read<CalorieHistoryViewModel>()
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
