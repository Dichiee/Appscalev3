import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppYesNoToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppYesNoToggle({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _option('NO', !value, () => onChanged(false))),
            const SizedBox(width: 8),
            Expanded(child: _option('YES', value, () => onChanged(true))),
          ],
        ),
      ],
    );
  }

  Widget _option(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.border),
        ),
        child: Text(
          text,
          style: AppTextStyles.label.copyWith(color: selected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}