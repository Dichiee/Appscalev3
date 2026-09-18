import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/dashboard_models.dart';

/// Sizes itself to its own content — no forced aspect ratio. Two of these
/// placed in an IntrinsicHeight Row will always match each other's height
/// naturally, and neither can ever overflow regardless of device font
/// scaling or screen density.
class StatCard extends StatelessWidget {
  final StatCardData data;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.data, this.onTap});
  

  @override
  Widget build(BuildContext context) {
     return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.label, style: AppTextStyles.body.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(data.value, style: AppTextStyles.h1.copyWith(fontSize: 24), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(data.subtitle, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Container(
            height: 4,
            decoration: BoxDecoration(color: data.accentColor, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    )
     );
  }
}