import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/child_status_filter.dart';
import '../../../shared/widgets/app_button.dart';
import '../utils/child_status_meta.dart';

class StatusFilterSheet extends StatefulWidget {
  final ChildStatusFilter current;

  const StatusFilterSheet({super.key, required this.current});

  static Future<ChildStatusFilter?> show(BuildContext context, ChildStatusFilter current) {
    return showModalBottomSheet<ChildStatusFilter>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatusFilterSheet(current: current),
    );
  }

  @override
  State<StatusFilterSheet> createState() => _StatusFilterSheetState();
}

class _StatusFilterSheetState extends State<StatusFilterSheet> {
  late ChildStatusFilter _filter = widget.current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text('Filter by nutritional status', style: AppTextStyles.h2.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () => setState(() => _filter = _filter.copyWith(onlyNotWeighed: !_filter.onlyNotWeighed)),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _filter.onlyNotWeighed ? AppColors.statRed.withOpacity(0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _filter.onlyNotWeighed ? AppColors.statRed : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: _filter.onlyNotWeighed ? AppColors.statRed : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Show only children not yet weighed',
                        style: AppTextStyles.body.copyWith(fontSize: 13, color: _filter.onlyNotWeighed ? AppColors.statRed : AppColors.textPrimary),
                      ),
                    ),
                    if (_filter.onlyNotWeighed) const Icon(Icons.check_circle, size: 18, color: AppColors.statRed),
                  ],
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _filter.onlyNotWeighed ? 0.35 : 1,
              child: IgnorePointer(
                ignoring: _filter.onlyNotWeighed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text('Weight-for-Age', style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    _chipGroup(
                      options: const ['All', 'Normal', 'Underweight', 'Severely Underweight'],
                      selected: _filter.weightForAge,
                      onSelected: (v) => setState(() => _filter = _filter.copyWith(weightForAge: v)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Height-for-Age (Stunting)', style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    _chipGroup(
                      options: const ['All', 'Normal', 'Stunted', 'Severely Stunted', 'Tall'],
                      selected: _filter.heightForAge,
                      onSelected: (v) => setState(() => _filter = _filter.copyWith(heightForAge: v)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Wasting (Weight-for-Length)', style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    _chipGroup(
                      options: const ['All', 'Normal', 'MAM', 'SAM', 'Overweight', 'Obese'],
                      selected: _filter.wasting,
                      onSelected: (v) => setState(() => _filter = _filter.copyWith(wasting: v)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => setState(() => _filter = const ChildStatusFilter()), child: const Text('Reset'))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: AppButton(label: 'Apply filter', onPressed: () => Navigator.pop(context, _filter))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipGroup({required List<String> options, required String selected, required ValueChanged<String> onSelected}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((status) {
        final isSelected = selected == status;
        final color = status == 'All' ? AppColors.primaryGreen : ChildStatusMeta.colorFor(status);
        return ChoiceChip(
          label: Text(status),
          selected: isSelected,
          onSelected: (_) => onSelected(status),
          selectedColor: color.withOpacity(0.16),
          labelStyle: TextStyle(color: isSelected ? color : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
          side: BorderSide(color: isSelected ? color : AppColors.border),
          backgroundColor: AppColors.surface,
        );
      }).toList(),
    );
  }
}