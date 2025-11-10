
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_settings.dart';
import '../../../../models/food_stats.dart';
import '../../../../models/foodstats_entry.dart';
import '../../../../widget/edit_delete_option_menu.dart';
import '../../helper/progress_visuals_helper.dart';
import '../../widget/caution_label_widget.dart';

class CalorieHistoryListview extends StatelessWidget {
  final List<FoodStatsEntry> monthStats;
  final DateTime pageDateTime;

  final void Function(DateTime) onEdit;
  final void Function(DateTime) onDelete;

  const CalorieHistoryListview(
      {required this.pageDateTime, required this.monthStats, required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    // Sort entries by ID (descending by date)
    final sortedStats = List<FoodStatsEntry>.from(monthStats);
      // ..sort((a, b) => b.id.compareTo(a.id));

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedStats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = sortedStats[index];
        final parts = entry.id.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        final cardDateTime = DateTime(pageDateTime.year, month, day);

        return _DayCard(
          dateTime: cardDateTime,
          foodStats: entry.stats,
          editDeleteOptionMenu: EditDeleteOptionMenu(
            onDelete: () => onDelete(cardDateTime),
            onEdit: () => onEdit(cardDateTime),
          ),
        );
      },
    );
  }

}

class _DayCard extends StatelessWidget {
  final DateTime dateTime;
  final FoodStats foodStats;
  final EditDeleteOptionMenu editDeleteOptionMenu;

  const _DayCard({
    // super.key,
    required this.dateTime,
    required this.foodStats,
    required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    String weekdayName = DateFormat('EEEE').format(dateTime);

    final cardDay = dateTime.day;
    final cardMonth = DateFormat.MMMM().format(dateTime);
    final cardYear = DateFormat.y().format(dateTime);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 2,
            child: editDeleteOptionMenu,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  '$cardDay $cardMonth, $cardYear ($weekdayName)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 4-column row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Progress Circle
                    _buildProgressCircle(),

                    const SizedBox(width: 8),

                    // Column 2: Calories info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${trimTrailingZero(foodStats.calories)} kcal',

                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              Text(
                                '/${AppSettings.atLeastCalories}',
                                style: TextStyle(
                                  fontSize: 10,
                                  // fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                'max(${AppSettings.atMaxCalories})',
                                style: TextStyle(
                                  fontSize:8,
                                  // fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],)

                          ],
                        ),
                        // if (foodStats.calories > AppSettings.atMaxCalories)

                        CationLabelWidget(foodStats: foodStats,)

                      ],
                    ),

                    const SizedBox(width: 8),

                    // Column 3: Nutrient chips
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          _buildNutrientChip('Protein', foodStats.proteins, Colors.pink.shade300),
                          _buildNutrientChip('Carbs', foodStats.carbohydrates, Colors.orange.shade300),
                          _buildNutrientChip('Fats', foodStats.fats, Colors.amber.shade400),
                          _buildNutrientChip('Vitamins', foodStats.vitamins, Colors.green.shade300),
                          _buildNutrientChip('Minerals', foodStats.minerals, Colors.blue.shade300),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProgressCircle() {



    final progress = getProgressRatio(foodStats);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0, end: progress > 1.0 ? 1.0 : progress),
      builder: (context, animatedValue, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                value: 1,
                color: Colors.grey.shade200,
              ),
            ),
            SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                value: animatedValue,
                color: getProgressCircleColor(foodStats),
                strokeCap: StrokeCap.round,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                // color: progress >= 1.0 ? Colors.redAccent : Colors.black,
                color: Colors.black,
              ),
              child: Text("${(progress * 100).toStringAsFixed(0)}%"),
            ),
          ],
        );
      },
    );
  }


  Widget _buildNutrientChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: color),
          const SizedBox(width: 2),
          Text(
            '$label: ${trimTrailingZero(value)}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }


}
