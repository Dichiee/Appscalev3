import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// The secondary/cancel action across the app. Same height and radius
/// as AppButton so the two sit evenly side by side, but with a visible
/// border and ripple so it unmistakably reads as tappable — never plain text.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.border, width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
        ),
        child: Text(label, style: AppTextStyles.label.copyWith(color: color, fontSize: 15)),
      ),
    );
  }
}