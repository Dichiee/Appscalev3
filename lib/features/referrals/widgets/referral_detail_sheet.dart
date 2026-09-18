import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/referral.dart';
import '../../masterlist/widgets/status_badge.dart';

/// Read-only referral detail sheet for BNS mobile users.
///
/// Status updates and clinical resolutions are managed exclusively by the
/// RHU Admin and BHW via the Web Health Portal; this sheet allows the mobile
/// user to track status and review clinical outcome notes.
class ReferralDetailSheet extends StatelessWidget {
  final Referral referral;

  const ReferralDetailSheet({
    super.key,
    required this.referral,
  });

  static Future<void> show(
    BuildContext context, {
    required Referral referral,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReferralDetailSheet(referral: referral),
    );
  }

  Color get _statusColor {
    switch (referral.status) {
      case 'Pending':
        return AppColors.statAmber;
      case 'In Progress':
        return AppColors.statBlue;
      case 'Completed':
        return AppColors.primaryGreen;
      case 'Cancelled':
        return AppColors.statRed;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${referral.createdAt.year}-${referral.createdAt.month.toString().padLeft(2, '0')}-${referral.createdAt.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.beneficiaryName,
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${referral.beneficiaryType == 'child' ? 'Child Beneficiary' : 'Mother Beneficiary'} · Barangay ${referral.barangay}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: referral.status, color: _statusColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Informational Notice regarding Web-Based Management
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGreenBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.darkGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Referral status and clinical resolutions are managed by the RHU Admin and BHW via the Web Health Portal.',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11.5,
                      color: AppColors.darkGreen,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildDetailRow('Date Filed', dateStr, Icons.calendar_today_outlined),
          const SizedBox(height: 10),
          _buildDetailRow('Referred Facility', referral.facility, Icons.local_hospital_outlined),
          const SizedBox(height: 10),
          _buildDetailRow('Reason for Referral', referral.reason, Icons.report_problem_outlined),
          const SizedBox(height: AppSpacing.lg),

          // Status & Outcome Section
          Text('Resolution & RHU Feedback', style: AppTextStyles.label.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      referral.status == 'Completed'
                          ? Icons.check_circle
                          : (referral.status == 'In Progress' ? Icons.timelapse : Icons.hourglass_top),
                      size: 16,
                      color: _statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      referral.status == 'Completed'
                          ? 'Resolved by RHU / BHW'
                          : (referral.status == 'In Progress' ? 'Under Review by RHU Staff' : 'Awaiting RHU Evaluation'),
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
                if (referral.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'RHU / BHW Notes:',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    referral.notes,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
