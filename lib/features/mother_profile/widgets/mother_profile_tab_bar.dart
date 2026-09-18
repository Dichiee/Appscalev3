import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MotherProfileTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const MotherProfileTabBar({super.key, required this.currentIndex, required this.onChanged});

  static const _labels = ['Info', 'Visits', 'Children'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isActive = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? const Color(0xFF9A2D5E) : Colors.transparent, width: 2.5))),
                alignment: Alignment.center,
                child: Text(_labels[index], style: TextStyle(color: isActive ? const Color(0xFF9A2D5E) : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        }),
      ),
    );
  }
}