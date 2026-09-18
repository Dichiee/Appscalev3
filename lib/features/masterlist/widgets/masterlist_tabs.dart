import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MasterlistTabs extends StatelessWidget {
  final int activeCount;
  final int inactiveCount;
  final bool showingActive;
  final ValueChanged<bool> onChanged;

  const MasterlistTabs({
    super.key,
    required this.activeCount,
    required this.inactiveCount,
    required this.showingActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tab('Active ($activeCount)', true),
        _tab('Inactive ($inactiveCount)', false),
      ],
    );
  }

  Widget _tab(String label, bool value) {
    final isSelected = showingActive == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isSelected ? AppColors.primaryGreen : Colors.transparent, width: 2.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}