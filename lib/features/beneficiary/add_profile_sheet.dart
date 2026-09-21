import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_outlined_button.dart';
import 'add_child_screen.dart';
import 'add_mother_screen.dart';
import '../../shared/utils/app_page_route.dart';

/// Opened from the Dashboard's docked "+" button. Purely navigational —
/// no data logic lives here.
class AddProfileSheet extends StatelessWidget {
  const AddProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle — signals this is a dismissible sheet before reading anything.
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            'What would you like to add?',
            style: AppTextStyles.h1.copyWith(fontSize: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a profile to register',
            style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AddOptionTile(
            icon: Icons.person_add_alt_1,
            accentColor: AppColors.primaryGreen,
            title: 'Add Child',
            subtitle: 'Register a new child profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, appPageRoute(const AddChildScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _AddOptionTile(
            icon: Icons.pregnant_woman,
            accentColor: AppColors.statBlue,
            title: 'Add Mother',
            subtitle: 'Register a new mother profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, appPageRoute(const AddMotherScreen()));
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppOutlinedButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accentColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.label.copyWith(color: accentColor, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_right, color: accentColor, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}