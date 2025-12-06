import 'package:flutter/material.dart';

class WeekDaysProgressWidget extends StatelessWidget {
  final Map<int, bool> weekStatus; // 1 = Mon → 7 = Sun
  const WeekDaysProgressWidget({super.key, required this.weekStatus});

  static const List<String> dayLabels = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];

  @override
  Widget build(BuildContext context) {
    int completed = weekStatus.values.where((v) => v == true).length;
    double progress = completed / 7;

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: false, // left to right
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              bool isDone = weekStatus[index + 1] ?? false;

              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 34,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green[400] : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      dayLabels[index],
                      style: TextStyle(fontSize: 11),
                    )
                  ],
                ),
              );
            },
          ),
        ),

      ],
    );
  }
}
