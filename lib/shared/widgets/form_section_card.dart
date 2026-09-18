import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The single grouping container used across every form in the app.
/// Personal Information, Guardian, Maternal Details, Linked Records —
/// all use this, so a BNS learns the pattern once and every future
/// screen (referrals, feeding sessions, transfers) reads the same way.
class FormSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool highlighted;

  const FormSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.primaryGreen : AppColors.border,
          width: highlighted ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: AppTextStyles.body.copyWith(fontSize: 12)),
          ],
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}