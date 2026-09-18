import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder for any tab/screen not built yet. Used by MainShell's
/// Program/Reports tabs and by the Programs tab inside Child Profile —
/// one honest "not built yet" visual instead of a blank screen or fake data.
class ComingSoonPlaceholder extends StatelessWidget {
  final String label;
  const ComingSoonPlaceholder({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('$label — coming next', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}