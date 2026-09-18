import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/local/feeding_attendance_repository.dart';
import '../../../../data/local/feeding_enrollment_repository.dart';
import '../../../../data/local/feeding_schedule_repository.dart';
import '../../../../data/local/measurement_repository.dart';
import '../../../../shared/utils/app_page_route.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../set_feeding_schedule_screen.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final enrolled = FeedingEnrollmentRepository().getEnrolledChildren(_currentBarangay);
    final loggedDays = FeedingAttendanceRepository().getLoggedDates(_currentBarangay).length;
    final rate = FeedingAttendanceRepository().getAttendanceRate(_currentBarangay);
    final schedule = FeedingScheduleRepository().get(_currentBarangay);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Schedule', style: AppTextStyles.h2.copyWith(fontSize: 16)),
            InkWell(
              onTap: () => Navigator.push(context, appPageRoute(const SetFeedingScheduleScreen())),
              child: Row(children: [
                Icon(schedule == null ? Icons.add_circle_outline : Icons.edit_outlined, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text(schedule == null ? 'Set schedule' : 'Edit', style: AppTextStyles.body.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: schedule == null
                ? Text('No feeding schedule set yet.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${schedule.daysSummary} · ${schedule.startTime} – ${schedule.endTime}', style: AppTextStyles.label.copyWith(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(schedule.location, style: AppTextStyles.body.copyWith(fontSize: 12)),
                    Text(schedule.endDate == null ? 'Ongoing' : 'Until ${schedule.endDate!.year}-${schedule.endDate!.month.toString().padLeft(2, '0')}-${schedule.endDate!.day.toString().padLeft(2, '0')}', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
                  ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Program Summary', style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: _StatBox(icon: Icons.groups_outlined, iconColor: AppColors.primaryGreen, value: '${enrolled.length}', label: 'Enrolled Children')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _StatBox(icon: Icons.event_note_outlined, iconColor: AppColors.statOrange, value: '$loggedDays', label: 'Days Logged')),
          ]),
          const SizedBox(height: AppSpacing.md),
          _StatBox(icon: Icons.check_circle_outline, iconColor: AppColors.statBlue, value: rate == null ? '—' : '${(rate * 100).round()}%', label: 'Attendance Rate', fullWidth: true),
          const SizedBox(height: AppSpacing.lg),
          Text('Weight trend per child', style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Individual trends since enrollment — a barangay-wide average would hide who is actually improving.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          if (enrolled.isEmpty)
            const EmptyState(icon: Icons.child_care_outlined, message: 'No children enrolled yet.')
          else
            ...enrolled.map((c) => _WeightTrendRow(childId: c.id, childName: c.fullName)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool fullWidth;
  const _StatBox({required this.icon, required this.iconColor, required this.value, required this.label, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.h1.copyWith(fontSize: 24)),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 11)),
      ]),
    );
  }
}

class _WeightTrendRow extends StatelessWidget {
  final String childId;
  final String childName;
  const _WeightTrendRow({required this.childId, required this.childName});

  @override
  Widget build(BuildContext context) {
    final measurements = MeasurementRepository().getForChildAscending(childId);
    String trendLabel = 'No measurements yet';
    Color trendColor = AppColors.textMuted;
    if (measurements.length >= 2) {
      final diff = measurements.last.weightKg - measurements.first.weightKg;
      trendLabel = '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg since enrollment';
      trendColor = diff > 0 ? AppColors.primaryGreen : (diff < 0 ? AppColors.statRed : AppColors.textMuted);
    } else if (measurements.length == 1) {
      trendLabel = 'Only 1 measurement so far';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: Text(childName, style: AppTextStyles.label.copyWith(fontSize: 13))),
        Text(trendLabel, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}