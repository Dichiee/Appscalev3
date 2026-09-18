import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_gradient_header.dart';

enum MasterlistCategory { children, mothers }

class MasterlistHeader extends StatelessWidget {
  final MasterlistCategory selected;
  final int childrenCount;
  final int mothersCount;
  final ValueChanged<MasterlistCategory> onChanged;

  const MasterlistHeader({
    super.key,
    required this.selected,
    required this.childrenCount,
    required this.mothersCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppGradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Master list', style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 20)),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _segment('Children ($childrenCount)', MasterlistCategory.children)),
                Expanded(child: _segment('Mothers ($mothersCount)', MasterlistCategory.mothers)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(String label, MasterlistCategory value) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.darkGreen : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}