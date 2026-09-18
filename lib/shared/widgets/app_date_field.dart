import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../utils/app_pickers.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    final effectiveFirst = firstDate ?? DateTime(1950);
    final effectiveLast = lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));
    final baseInitial = value ?? DateTime.now();
    final clampedInitial = baseInitial.isBefore(effectiveFirst)
        ? effectiveFirst
        : (baseInitial.isAfter(effectiveLast) ? effectiveLast : baseInitial);

    final picked = await showAppDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: effectiveFirst,
      lastDate: effectiveLast,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'dd/mm/yyyy'
                        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
                    style: AppTextStyles.body.copyWith(
                      color: value == null ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}