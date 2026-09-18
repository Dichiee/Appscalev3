import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/app_data_bus.dart';
import '../../../data/local/deworming_repository.dart';
import '../../../data/local/feeding_attendance_repository.dart';
import '../../../data/local/feeding_enrollment_repository.dart';
import '../../../data/local/vitamin_a_repository.dart';
import '../../../data/models/child.dart';
import '../../../shared/utils/app_page_route.dart';
import '../../program/deworming/record_deworming_screen.dart';
import '../../program/feeding/feeding_program_screen.dart';
import '../../program/vitamin_a/record_vitamin_a_screen.dart';

class ChildProgramsTab extends StatelessWidget {
  final Child child;

  const ChildProgramsTab({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, version, childWidget) {
        final isEnrolledInFeeding = FeedingEnrollmentRepository().isEnrolled(child.id);
        final enrolledDate = FeedingEnrollmentRepository().enrolledAt(child.id);
        final vitARecords = VitaminARepository().getByChildId(child.id);
        final dewormingRecords = DewormingRepository().getByChildId(child.id);

        // Calculate attendance
        final attRepo = FeedingAttendanceRepository();
        final loggedDates = attRepo.getLoggedDates(child.barangay);
        var daysPresent = 0;
        for (final d in loggedDates) {
          final statuses = attRepo.getForDate(child.barangay, d);
          if (statuses[child.id] == 'Present') {
            daysPresent++;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildFeedingSection(context, isEnrolledInFeeding, enrolledDate, daysPresent),
            const SizedBox(height: AppSpacing.lg),
            _buildVitaminASection(context, vitARecords),
            const SizedBox(height: AppSpacing.lg),
            _buildDewormingSection(context, dewormingRecords),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }

  Widget _buildFeedingSection(
    BuildContext context,
    bool isEnrolled,
    DateTime? enrolledDate,
    int daysPresent,
  ) {
    final isSamOrMam = child.wastingStatus == 'SAM' ||
        child.wastingStatus == 'MAM' ||
        child.nutritionStatus.contains('Underweight');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.soup_kitchen_outlined, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('120-Day Feeding Program', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    Text(
                      isEnrolled ? 'Active Beneficiary' : 'Not Currently Enrolled',
                      style: AppTextStyles.caption.copyWith(
                        color: isEnrolled ? AppColors.primaryGreen : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEnrolled
                      ? AppColors.primaryGreen.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEnrolled ? 'ENROLLED' : 'NOT ENROLLED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isEnrolled ? AppColors.primaryGreen : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          if (isEnrolled) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Days Attended', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('$daysPresent / 120 days', style: AppTextStyles.h3.copyWith(fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enrolled Since', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      enrolledDate != null
                          ? '${enrolledDate.month}/${enrolledDate.day}/${enrolledDate.year}'
                          : '—',
                      style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(child.wastingStatus, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (daysPresent / 120).clamp(0.0, 1.0),
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
                side: const BorderSide(color: AppColors.primaryGreen),
              ),
              icon: const Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryGreen),
              label: const Text('View Feeding Program', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
              onPressed: () {
                Navigator.push(context, appPageRoute(const FeedingProgramScreen()));
              },
            ),
          ] else ...[
            Text(
              isSamOrMam
                  ? '⚠️ Child is flagged as ${child.wastingStatus} / ${child.nutritionStatus} and is eligible for emergency supplementary feeding.'
                  : 'Child is not enrolled in the 120-day supplementary feeding program.',
              style: AppTextStyles.caption.copyWith(
                color: isSamOrMam ? AppColors.statOrange : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSamOrMam ? AppColors.darkGreen : AppColors.surface,
                foregroundColor: isSamOrMam ? Colors.white : AppColors.darkGreen,
                minimumSize: const Size(double.infinity, 36),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Enroll in Feeding Program', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await FeedingEnrollmentRepository().enroll(child.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${child.fullName} enrolled in Feeding Program'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitaminASection(BuildContext context, List<dynamic> vitARecords) {
    final age = child.ageInMonths;
    final recommendedDose = VitaminARepository.determineRecommendedDosage(age);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.statAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication_outlined, color: AppColors.statAmber, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vitamin A Supplementation', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    Text('Recommended: $recommendedDose', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.darkGreen),
                tooltip: 'Record Dose',
                onPressed: () {
                  Navigator.push(
                    context,
                    appPageRoute(RecordVitaminAScreen(initialChild: child)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          if (vitARecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text('No Vitamin A records yet', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ),
            )
          else
            ...vitARecords.map((r) {
              final dateStr = '${r.dateGiven.month}/${r.dateGiven.day}/${r.dateGiven.year}';
              final isBlue = r.dosage.contains('Blue');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: isBlue ? Colors.blue : Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${r.dosage} — $dateStr (${r.doseType})',
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                      ),
                    ),
                    Text('By ${r.administeredBy}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDewormingSection(BuildContext context, List<dynamic> dewormingRecords) {
    final isEligible = DewormingRepository.isEligible(child.ageInMonths);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.statOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.healing_outlined, color: AppColors.statOrange, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deworming Program', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                    Text(
                      isEligible ? 'Eligible for mass deworming (12-59 mos)' : 'Under 12 months (Not eligible)',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: isEligible ? AppColors.darkGreen : AppColors.statRed,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEligible)
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.darkGreen),
                  tooltip: 'Record Deworming',
                  onPressed: () {
                    Navigator.push(
                      context,
                      appPageRoute(RecordDewormingScreen(initialChild: child)),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          if (dewormingRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text('No Deworming records yet', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ),
            )
          else
            ...dewormingRecords.map((r) {
              final dateStr = '${r.dateGiven.month}/${r.dateGiven.day}/${r.dateGiven.year}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.statOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${r.drugName} — $dateStr (${r.round})',
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                      ),
                    ),
                    Text('By ${r.administeredBy}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
