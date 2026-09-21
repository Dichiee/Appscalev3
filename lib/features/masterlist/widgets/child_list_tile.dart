import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/child.dart';
import '../utils/child_status_meta.dart';
import 'status_badge.dart';

class ChildListTile extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;

  const ChildListTile({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final needsAttention = ChildStatusMeta.needsAttention(child.nutritionStatus);
    final extraBadges = <Widget>[];
    if (child.wastingStatus != 'Normal' && child.wastingStatus != 'Not weighed') {
      extraBadges.add(StatusBadge(label: child.wastingStatus, color: ChildStatusMeta.colorFor(child.wastingStatus)));
    }
    if (child.stuntingStatus == 'Stunted' || child.stuntingStatus == 'Severely Stunted') {
      extraBadges.add(StatusBadge(label: child.stuntingStatus, color: ChildStatusMeta.colorFor(child.stuntingStatus)));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: needsAttention ? AppColors.statRed.withValues(alpha: 0.06) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: needsAttention ? AppColors.statRed.withValues(alpha: 0.3) : AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (needsAttention)
                  const Padding(padding: EdgeInsets.only(right: 8, top: 2), child: Icon(Icons.error_outline, size: 18, color: AppColors.statRed)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.fullName, style: AppTextStyles.label.copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${child.ageInMonths} mos · ${child.address}', style: AppTextStyles.body.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(label: child.nutritionStatus, color: ChildStatusMeta.colorFor(child.nutritionStatus)),
                    if (extraBadges.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(spacing: 4, runSpacing: 4, alignment: WrapAlignment.end, children: extraBadges),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}