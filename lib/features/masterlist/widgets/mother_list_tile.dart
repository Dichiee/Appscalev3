import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/mother.dart';
import '../utils/mother_status_meta.dart';
import 'status_badge.dart';

class MotherListTile extends StatelessWidget {
  final Mother mother;
  final VoidCallback onTap;

  const MotherListTile({super.key, required this.mother, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = mother.isActive ? MotherStatusMeta.colorFor(mother.riskStatus) : AppColors.textMuted;
    final label = mother.isActive ? mother.riskStatus : 'Inactive';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mother.fullName, style: AppTextStyles.label.copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(mother.address, style: AppTextStyles.body.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                StatusBadge(label: label, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}