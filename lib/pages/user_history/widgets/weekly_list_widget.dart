import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class WeeklyListWidget extends StatelessWidget {
  const WeeklyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // <-- MAIN HEIGHT
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (context, index) {
          final color = AppColors.colorPalette[index % AppColors.colorPalette.length];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Row(
                children: [
                  // Left Accent Bar
                  Container(
                    width: 7,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.80),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Centered Content
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Week ${index + 11}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 14)
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "12,000 kcal",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
