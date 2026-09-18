import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class FeedingHeader extends StatelessWidget {
  const FeedingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.soup_kitchen_outlined, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Feeding Program', style: AppTextStyles.label.copyWith(fontSize: 16)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(20)),
                    child: Text('Active', style: TextStyle(color: AppColors.darkGreen, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ]),
                Text('Promote proper nutrition through supplementary feeding activities.', style: AppTextStyles.body.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}