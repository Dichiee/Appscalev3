import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/child.dart';
import '../../masterlist/utils/child_status_meta.dart';
import '../../masterlist/widgets/status_badge.dart';

class ChildProfileHeader extends StatelessWidget {
  final Child child;
  final bool isActive;
  final VoidCallback onEditPressed;
  final VoidCallback onStatusActionPressed;
  final VoidCallback onMeasurePressed;

  const ChildProfileHeader({
    super.key,
    required this.child,
    required this.isActive,
    required this.onEditPressed,
    required this.onStatusActionPressed,
    required this.onMeasurePressed,
  });

  @override
  Widget build(BuildContext context) {
    final showStuntingBadge = child.stuntingStatus == 'Stunted' || child.stuntingStatus == 'Severely Stunted';
    final showWastingBadge = child.wastingStatus == 'SAM' || child.wastingStatus == 'MAM';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryGreen, AppColors.darkGreen]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single row: arrow -> title -> Measure -> overflow menu.
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pop(context),
                child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, color: Colors.white)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Child Profile',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isActive) ...[
                _MeasureButton(onPressed: onMeasurePressed),
                const SizedBox(width: 8),
              ],
              _OverflowMenu(isActive: isActive, onEditPressed: onEditPressed, onStatusActionPressed: onStatusActionPressed),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(child.initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.fullName, style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 17)),
                    const SizedBox(height: 2),
                    Text('${child.ageLabel} · ${child.address}', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                    Text('Born: ${_formatDate(child.birthDate)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (isActive) ...[
                StatusBadge(label: child.nutritionStatus, color: ChildStatusMeta.colorFor(child.nutritionStatus), onDark: true),
                if (showStuntingBadge) StatusBadge(label: child.stuntingStatus, color: ChildStatusMeta.colorFor(child.stuntingStatus), onDark: true),
                if (showWastingBadge) StatusBadge(label: child.wastingStatus, color: ChildStatusMeta.colorFor(child.wastingStatus), onDark: true),
              ] else
                StatusBadge(label: 'Inactive · ${child.inactiveReason ?? "Unspecified"}', color: AppColors.textMuted, onDark: true),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _OverflowMenu extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEditPressed;
  final VoidCallback onStatusActionPressed;

  const _OverflowMenu({required this.isActive, required this.onEditPressed, required this.onStatusActionPressed});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEditPressed();
        if (value == 'status') onStatusActionPressed();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary), SizedBox(width: 10), Text('Edit profile')])),
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(isActive ? Icons.person_off_outlined : Icons.replay, size: 18, color: isActive ? AppColors.statRed : AppColors.primaryGreen),
              const SizedBox(width: 10),
              Text(isActive ? 'Mark as inactive' : 'Reactivate'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeasureButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _MeasureButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white, size: 15),
              SizedBox(width: 3),
              Text('Measure', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}