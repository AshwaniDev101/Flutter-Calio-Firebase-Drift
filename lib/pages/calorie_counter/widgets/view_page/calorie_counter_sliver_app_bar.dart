
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../user_history/view_model.dart';
import '../../../user_history/view_page.dart';
import '../../view_model.dart';
import '../micro_widgets/calorie_appbar_title.dart';

class CalorieCounterSliverAppBar extends StatelessWidget {
  final CalorieCounterViewModel viewModel;

  const CalorieCounterSliverAppBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,

      // pinned: false,
      snap: true,
      pinned: true,
      backgroundColor: AppColors.appbar,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: CalorieAppBarTitle(date: viewModel.pageDateTime, onDateSelected: viewModel.updatePageDateTime),
      actions: viewModel.isOldPage
          ? []
          : [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: InkWell(
            onTap: () => _openHistory(context, viewModel),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.appbarContent, size: 22),
                const SizedBox(width: 6),
                Text('History', style: TextStyle(fontSize: 14, color: AppColors.appbarContent, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Navigate to the history page
  void _openHistory(BuildContext context, CalorieCounterViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CalorieFoodStatsHistoryViewModel(pageDateTime: vm.pageDateTime),
          child: CalorieHistoryPage(),
        ),
      ),
    );
  }
}