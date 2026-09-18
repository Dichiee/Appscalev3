import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Shared shell for the app's rounded-bottom green headers (Dashboard,
/// Masterlist, and any future primary screen). Guarantees identical
/// color, padding, corner radius, and a shared minimum height — so a
/// screen with less content never visually reads as "shorter" than one
/// with more. Only the content inside should ever differ.
class AppGradientHeader extends StatelessWidget {
  final Widget child;
  const AppGradientHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSpacing.headerMinHeight),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: child,
    );
  }
}