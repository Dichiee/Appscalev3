import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/local/feeding_enrollment_repository.dart';
import '../../../../data/local/measurement_repository.dart';
import '../../../../data/models/child.dart';
import '../../../../shared/utils/app_page_route.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../child_profile/add_measurement_screen.dart';
import '../../../masterlist/utils/child_status_meta.dart';
import '../../../masterlist/widgets/status_badge.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class WeighingTab extends StatelessWidget {
  const WeighingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final enrolled = FeedingEnrollmentRepository().getEnrolledChildren(_currentBarangay);
    final priorityCount = enrolled.where((c) => c.nutritionStatus == 'Severely Underweight' || c.wastingStatus == 'SAM' || c.wastingStatus == 'MAM').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (priorityCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.statRed.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.statRed.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.statRed, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('$priorityCount enrolled child${priorityCount == 1 ? '' : 'ren'} flagged SAM/MAM/Underweight — prioritize at the next weighing.', style: AppTextStyles.body.copyWith(fontSize: 12, color: const Color(0xFF7A1F1F)))),
              ]),
            ),
          Text('${enrolled.length} enrolled children', style: AppTextStyles.h2.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text('Latest weight is read from the Child Profile — tap "Weigh" to record a new measurement there directly.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.md),
          if (enrolled.isEmpty)
            const EmptyState(icon: Icons.monitor_weight_outlined, message: 'No children enrolled yet.')
          else
            ...enrolled.map((c) => _ChildWeighRow(child: c)),
        ],
      ),
    );
  }
}

class _ChildWeighRow extends StatelessWidget {
  final Child child;
  const _ChildWeighRow({required this.child});

  @override
  Widget build(BuildContext context) {
    final measurements = MeasurementRepository().getForChild(child.id);
    final latest = measurements.isNotEmpty ? measurements.first : null;
    final isPriority = child.nutritionStatus == 'Severely Underweight' || child.wastingStatus == 'SAM' || child.wastingStatus == 'MAM';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPriority ? AppColors.statRed.withValues(alpha: 0.04) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPriority ? AppColors.statRed.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.lightGreenBg, child: Text(child.initials, style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(child.fullName, style: AppTextStyles.label.copyWith(fontSize: 13)),
                if (isPriority) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.statRed.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text('Priority', style: TextStyle(color: AppColors.statRed, fontSize: 9, fontWeight: FontWeight.w700))),
                ],
              ]),
              Text(latest == null ? 'Not yet weighed · Last: —' : '${latest.weightKg} kg · Last: ${latest.date.month}/${latest.date.day}', style: AppTextStyles.body.copyWith(fontSize: 11)),
              const SizedBox(height: 4),
              StatusBadge(label: child.nutritionStatus, color: ChildStatusMeta.colorFor(child.nutritionStatus)),
            ]),
          ),
          OutlinedButton(
            // showReferralPrompt: false — this is a quick weigh-in inside an
            // already-enrolled feeding session, not the first time this
            // child's severe status is being discovered.
            onPressed: () => Navigator.push(context, appPageRoute(AddMeasurementScreen(child: child, showReferralPrompt: false))),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Weigh', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}