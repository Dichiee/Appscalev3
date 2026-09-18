import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_outlined_button.dart';

/// The one referral-prompt dialog used by both the child measurement
/// flow and the mother visit flow — same visual treatment, same
/// behavior, so a BNS learns it once. Navigation on "Create Referral"
/// is left to the caller, since child and mother route to the same
/// form with different prefill data.
class UrgentReferralDialog {
  UrgentReferralDialog._();

  static Future<void> show(
    BuildContext context, {
    required String beneficiaryName,
    required String reason,
    required VoidCallback onCreateReferral,
    VoidCallback? onLater,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.statRed.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.statRed, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Urgent attention may be needed', textAlign: TextAlign.center, style: AppTextStyles.h2.copyWith(fontSize: 17, color: AppColors.primaryGreen)),
              const SizedBox(height: 8),
              Text('Create a referral for $beneficiaryName now?', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text('This suggests:', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(reason, textAlign: TextAlign.center, style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.statRed)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton(label: 'Create Referral', onPressed: () { Navigator.pop(context); onCreateReferral(); }),
              const SizedBox(height: 10),
              AppOutlinedButton(label: 'Later', onPressed: () { Navigator.pop(context); onLater?.call(); }),
            ],
          ),
        ),
      ),
    );
  }
}