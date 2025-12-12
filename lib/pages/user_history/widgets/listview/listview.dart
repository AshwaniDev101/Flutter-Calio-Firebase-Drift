
import 'package:flutter/material.dart';
import '../../../../../models/food_stats_entry.dart';
import '../../../../widgets/edit_delete_option_menu/edit_delete_option_menu.widget.dart';
import 'card.dart';


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

        return DayCard(
          dateTime: cardDateTime,
          foodStats: entry.stats,
          editDeleteOptionMenu: EditDeleteOptionMenuWidget(
            onDelete: () => onDelete(cardDateTime),
            onEdit: () => onEdit(cardDateTime),
          ),
        );
      },
    );
  }

}







