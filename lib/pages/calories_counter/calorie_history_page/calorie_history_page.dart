
import 'package:calio/pages/calories_counter/calorie_history_page/viewmodel/calorie_food_stats_history_view_model.dart';
import 'package:calio/pages/calories_counter/calorie_history_page/widgets/calorie_history_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../calorie_counter_page/calories_counter_page.dart';
import '../helper/progress_visuals_helper.dart';

/// Main page displaying calorie history for a month
class CalorieHistoryPage extends StatefulWidget {
  const CalorieHistoryPage({super.key});

  @override
  State<CalorieHistoryPage> createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalorieFoodStatsHistoryViewModel>().loadMonthStats();
    });
  }

  Widget _buildExcessLabel(vm) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            vm.excessCalories > 0 ? "Kcal Gained : " : "Kcal Lost : (${vm.monthStatsMap.length} Days) : ",
            style: TextStyle(fontSize: 12),
          ),
          Text("${trimTrailingZero(vm.excessCalories)} Kcal",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: vm.excessCalories > 0 ? Colors.red : Colors.green)),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieFoodStatsHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          title: Text(
            'Calorie History',
            style: AppTextStyle.appBarTextStyle,
          ),
          centerTitle: true,
          // elevation: 2,
          backgroundColor: AppColors.appbar,
          iconTheme: IconThemeData(color: AppColors.appbarContent),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'settings') {
                  print('Settings selected');
                } else if (value == 'add') {
                  // vm.runTest();
                  // Run test
                } else if (value == 'test2') {
                  print('Test 2 selected');
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.pink),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey[600]),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
      body: SafeArea(
        child: Column(
          children: [
            _buildExcessLabel(vm),
            vm.monthStatsMap.isEmpty
                ? const Center(child: Text('No data found'))
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: vm.loadMonthStats,
                      child: CalorieHistoryListview(
                        pageDateTime: vm.pageDateTime,
                        monthStats: vm.monthStatsMap,
                        onEdit: (DateTime cardDateTime) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalorieCounterPage(pageDateTime: cardDateTime),
                            ),
                          ).then((_) {
                            vm.loadMonthStats();
                          });
                        },
                        onDelete: (DateTime cardDateTime) {
                          vm.onDelete(cardDateTime);
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
