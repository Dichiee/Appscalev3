import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EmptyListState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyListState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}