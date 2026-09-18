import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/referral.dart';
import '../../masterlist/widgets/status_badge.dart';
import 'referral_detail_sheet.dart';

class ReferralCard extends StatelessWidget {
  final Referral referral;
  final bool showBeneficiaryName;

  const ReferralCard({
    super.key,
    required this.referral,
    this.showBeneficiaryName = false,
  });

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

  void _openDetailSheet(BuildContext context) {
    ReferralDetailSheet.show(
      context,
      referral: referral,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDetailSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showBeneficiaryName)
                            Text(referral.beneficiaryName, style: AppTextStyles.label.copyWith(fontSize: 14)),
                          Text(
                            '${referral.createdAt.year}-${referral.createdAt.month.toString().padLeft(2, '0')}-${referral.createdAt.day.toString().padLeft(2, '0')}',
                            style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: referral.status, color: _statusColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(referral.reason, style: AppTextStyles.body.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        referral.facility,
                        style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View details',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.darkGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right, size: 14, color: AppColors.darkGreen),
                      ],
                    ),
                  ],
                ),
                if (referral.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          referral.status == 'Completed' ? Icons.check_circle_outline : Icons.notes,
                          size: 13,
                          color: _statusColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            referral.status == 'Completed'
                                ? 'RHU Resolution: ${referral.notes}'
                                : 'RHU Note: ${referral.notes}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}