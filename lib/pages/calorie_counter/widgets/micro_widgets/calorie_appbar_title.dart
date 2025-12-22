
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/helpers/date_time_helper.dart';
import '../../../../theme/app_colors.dart';

// AppBar title widget
class CalorieAppBarTitle extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const CalorieAppBarTitle({required this.date, required this.onDateSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final isToday = DateTimeHelper.isSameDate(date, DateTime.now());
    final formatted = '${date.day}/${date.month}/${date.year}';
    final weekday = DateFormat('EEEE').format(date);

    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selected != null) onDateSelected(selected);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isToday ? 'Today' : formatted, style: AppTextStyle.appBarTextStyle),
          Text(
            isToday ? formatted : '($weekday)',
            style: AppTextStyle.appBarTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
