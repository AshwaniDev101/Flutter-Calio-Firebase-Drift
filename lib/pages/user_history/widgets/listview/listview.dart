import 'package:flutter/material.dart';

import '../../../../core/helpers/date_time_helper.dart';
import '../../../../models/food_stats_entry.dart';
import '../../../../widgets/edit_delete_option_menu/edit_delete_option_menu.widget.dart';
import 'card.dart'; // DayCard widget

/// A scrollable list of daily calorie history cards for a given month/year.
///
/// Displays [FoodStatsEntry] items as [DayCard]s, sorted from most recent to oldest.
/// Includes edit/delete options via popup menu.
class CalorieHistoryListview extends StatelessWidget {
  final List<FoodStatsEntry> monthStats;
  final DateTime pageDateTime; // Provides the year context
  final void Function(DateTime) onEdit;
  final void Function(DateTime) onDelete;

  const CalorieHistoryListview({
    super.key,
    required this.monthStats,
    required this.pageDateTime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Sort entries by date descending (most recent first)
    // Assuming monthStats comes from repository already ordered descending,
    // but we defensively sort here using the full date reconstructed from ID + year
    final sortedStats = List<FoodStatsEntry>.from(monthStats)
      ..sort((a, b) {
        final dateA = DateTimeHelper.fromDayMonthId(a.id, pageDateTime.year);
        final dateB = DateTimeHelper.fromDayMonthId(b.id, pageDateTime.year);
        return dateB.compareTo(dateA); // descending
      });

    if (sortedStats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No data for this month yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: sortedStats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = sortedStats[index];
        final cardDateTime = DateTimeHelper.fromDayMonthId(entry.id, pageDateTime.year);

        return DayCard(
          dateTime: cardDateTime,
          foodStats: entry.foodStats,
          editDeleteOptionMenu: EditDeleteOptionMenuWidget(
            onEdit: () => onEdit(cardDateTime),
            onDelete: () => onDelete(cardDateTime),
          ),
        );
      },
    );
  }
}