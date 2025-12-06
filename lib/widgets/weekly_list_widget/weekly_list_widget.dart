import 'package:flutter/material.dart';

class WeeklyListWidget extends StatelessWidget {
  const WeeklyListWidget({super.key});

  final bool isPerfect = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.green[400],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Week ${index + 11}",style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                SizedBox(height: 2),
                Text("${index + 100} kcal",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
