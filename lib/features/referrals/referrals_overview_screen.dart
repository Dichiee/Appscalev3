import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/referral_needs_service.dart';
import '../../data/local/referral_repository.dart';
import '../../shared/utils/app_page_route.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/empty_state.dart';
import 'create_referral_screen.dart';
import 'widgets/referral_card.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class ReferralsOverviewScreen extends StatelessWidget {
  const ReferralsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Referral Monitoring', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: AppDataBus.version,
                builder: (context, version, child) {
                  final needs = ReferralNeedsService();
                  final childrenNeeding = needs.getChildrenNeedingReferral(_currentBarangay);
                  final mothersNeeding = needs.getMothersNeedingReferral(_currentBarangay);
                  final referrals = ReferralRepository().getForBarangay(_currentBarangay);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppButton(
                          label: '+ New Referral',
                          onPressed: () => Navigator.push(context, appPageRoute(const CreateReferralScreen())),
                        ),
                        if (childrenNeeding.isNotEmpty || mothersNeeding.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text('Needs referral', style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.statRed)),
                          const SizedBox(height: 4),
                          Text('Currently severe or at-risk, no referral opened yet.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: AppSpacing.sm),
                          ...childrenNeeding.map((c) => _NeedsReferralTile(
                                name: c.fullName,
                                subtitle: '${c.ageInMonths} mos · ${c.address}',
                                reason: [c.nutritionStatus, c.stuntingStatus, c.wastingStatus].where((s) => s.startsWith('Severely') || s == 'SAM').join(', '),
                                onCreate: () => Navigator.push(context, appPageRoute(CreateReferralScreen(
                                  prefillBeneficiaryType: 'child',
                                  prefillBeneficiaryId: c.id,
                                  prefillBeneficiaryName: c.fullName,
                                  prefillBeneficiarySubtitle: '${c.ageInMonths} mos · ${c.address}',
                                ))),
                              )),
                          ...mothersNeeding.map((m) => _NeedsReferralTile(
                                name: m.fullName,
                                subtitle: m.address,
                                reason: 'At-risk',
                                onCreate: () => Navigator.push(context, appPageRoute(CreateReferralScreen(
                                  prefillBeneficiaryType: 'mother',
                                  prefillBeneficiaryId: m.id,
                                  prefillBeneficiaryName: m.fullName,
                                ))),
                              )),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Text('Referral records', style: AppTextStyles.h2.copyWith(fontSize: 15)),
                        const SizedBox(height: AppSpacing.sm),
                        if (referrals.isEmpty)
                          const EmptyState(icon: Icons.local_hospital_outlined, message: 'No referrals recorded yet.')
                        else
                          ...referrals.map((r) => ReferralCard(referral: r, showBeneficiaryName: true)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedsReferralTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String reason;
  final VoidCallback onCreate;

  const _NeedsReferralTile({required this.name, required this.subtitle, required this.reason, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.statRed.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.statRed.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.label.copyWith(fontSize: 14)),
                Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
                Text(reason, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.statRed, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(backgroundColor: AppColors.statRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Create', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}