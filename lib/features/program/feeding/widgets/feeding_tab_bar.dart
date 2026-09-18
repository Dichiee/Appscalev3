import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeedingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const FeedingTabBar({super.key, required this.currentIndex, required this.onChanged});

  static const _labels = ['Overview', 'Attendance', 'Meal Plan', 'Weighing'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_labels.length, (i) {
          final isActive = i == currentIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? AppColors.primaryGreen : Colors.transparent, width: 2.5))),
                child: Text(_labels[i], style: TextStyle(color: isActive ? AppColors.primaryGreen : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        }),
      ),
    );
  }
}