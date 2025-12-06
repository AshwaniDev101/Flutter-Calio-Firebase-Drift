import 'package:calio/models/foodstats_entry.dart';
import 'package:calio/pages/user_history/view_model.dart';
import 'package:calio/pages/user_history/widgets/listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../helper/progress_visuals_helper.dart';
import '../../widgets/weekdays_progress_widget/weekdays_progress_widget.dart';
import '../../widgets/weekly_list_widget/weekly_list_widget.dart';
import '../calorie_counter/calorie_counter_page.dart';

/// Main page displaying calorie user_history for a month
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                vm.excessCalories > 0 ? "Kcal Gained : " : "Kcal Lost : (${vm.monthStatsMap.length} Days) : ",
                style: TextStyle(fontSize: 12),
              ),
              Text(
                "${trimTrailingZero(vm.excessCalories)} Kcal (${kcalToWeightString(vm.excessCalories)})",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: vm.excessCalories > 0 ? Colors.red : Colors.green,
                ),
              ),

              SizedBox(width: 10),
            ],
          ),
          getLowerLabel(vm),
        ],
      ),
    );
  }

  Widget getLowerLabel(vm) {
    var severDayDum = sumFirstSevenCalories(vm);
    return Text(
      "7Days ${trimTrailingZero(severDayDum)} Kcal (${kcalToWeightString(severDayDum)})",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: vm.excessCalories > 0 ? Colors.red : Colors.green,
      ),
    );
  }

  String kcalToWeightString(double kcal) {
    const double kcalPerKg = 7700;

    double totalKg = kcal / kcalPerKg;

    int kg = totalKg.floor(); // whole kilograms
    int g = ((totalKg - kg) * 1000).round(); // remaining grams

    return "${kg}kg${g}g";
  }

  double sumFirstSevenCalories(vm) {
    List<FoodStatsEntry> items = vm.monthStatsMap;

    int limit = items.length < 7 ? items.length : 7;

    double total = 0;
    for (int i = 0; i < limit; i++) {
      var diff = items[i].stats.calories - 1700;
      total += diff;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieFoodStatsHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Calorie History', style: AppTextStyle.appBarTextStyle),
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
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.pink),
                        SizedBox(width: 10),
                        Text('Add', style: TextStyle(color: Colors.pink)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.grey[600]),
                        const SizedBox(width: 10),
                        Text('Settings', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildExcessLabel(vm),
            WeekDaysProgressWidget(weekStatus: {1: true, 2: true, 3: true, 4: false, 5: false, 6: false, 7: false}),
            WeeklyListWidget(),

            // Container(color: Colors.green,height: 50,),
            // // heatLevelMap:{'1':10,'2':20,'3':30,'4':40,'5':50,'6':60,'7':70,'8':80,'9':90,'10':100}
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
                            builder: (context) => CalorieCounterPage(pageDateTime: cardDateTime, isOldPage: true),
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

  //
  // Stream<Map<String, dynamic>> dummyStream() async* {
  //   int counter = 0;
  //
  //   while (true) {
  //     await Future.delayed(Duration(seconds: 1));
  //
  //     yield {
  //
  //     };
  //
  //     counter++;
  //   }
  // }
}
