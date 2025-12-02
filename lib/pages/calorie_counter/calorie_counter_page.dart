import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:calio/pages/calorie_counter/widgets/calorie_counter_sliver_app_bar.dart';
import 'package:calio/pages/calorie_counter/widgets/food_list_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/top_progress_sliver.dart';
import 'package:calio/pages/calorie_counter/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diet_food.dart';
import '../../theme/app_colors.dart';
import 'add_new/add_edit_dialog.dart';

class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;
  final bool isOldPage;

  // Page-level widget that provides the ViewModel to the subtree.
  CalorieCounterPage({Key? key, required this.pageDateTime, this.isOldPage = false})
    : super(key: key ?? ValueKey(pageDateTime));

  @override
  Widget build(BuildContext context) {
    // Creates the ViewModel for the page.
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
    final vm = context.watch<CalorieCounterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar
            CalorieCounterSliverAppBar(viewModel: vm),
            // Top semicircle progress
            TopProgressSliver(viewModel: vm),
            // Search bar
            SliverPadding(padding: EdgeInsets.all(12), sliver: SliverToBoxAdapter(child: MySearchBar())),
            // Food list sliver
            FoodListSliver(viewModel: vm),
          ],
        ),
      ),
    );
  }
}




