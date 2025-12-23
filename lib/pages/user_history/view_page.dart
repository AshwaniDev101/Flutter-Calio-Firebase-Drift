import 'package:calio/pages/user_history/view_model.dart';
import 'package:calio/pages/user_history/widgets/listview/listview.dart';
import 'package:calio/pages/user_history/widgets/weekly_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../calorie_counter/view_page.dart';

class CalorieHistoryPage extends StatelessWidget {
  const CalorieHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalorieHistoryViewModel(pageDateTime: DateTime.now()),
      child: const _CalorieHistoryPageBody(),
    );
  }
}

class _CalorieHistoryPageBody extends StatelessWidget {
  const _CalorieHistoryPageBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Calorie History', style: AppTextStyle.appBarTextStyle),
        centerTitle: true,
        backgroundColor: AppColors.appbar,
        iconTheme: IconThemeData(color: AppColors.appbarContent),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'monthly_stats':
                  print('Monthly stats selected');
                  break;
                case 'settings':
                  print('Settings selected');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'monthly_stats',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.blueGrey[700]),
                    const SizedBox(width: 10),
                    Text('Monthly Stats', style: TextStyle(color: Colors.blueGrey[700])),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blueGrey[700]),
                    const SizedBox(width: 10),
                    Text('Settings', style: TextStyle(color: Colors.blueGrey[700])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: vm.yearStatsList.isEmpty
            ? const Center(child: Text('No data found'))
            : Column(
                children: [
                  WeeklyListWidget(
                    weekStatsList: vm.weeklyStatsList,
                  ),
                  Expanded(
                    child: CalorieHistoryListview(
                      pageDateTime: vm.pageDateTime,
                      monthStats: vm.yearStatsList,
                      onEdit: (DateTime cardDateTime) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalorieCounterPage(pageDateTime: cardDateTime, isOldPage: true),
                          ),
                        );
                      },
                      onDelete: (DateTime cardDateTime) {
                        vm.onDelete(cardDateTime);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
