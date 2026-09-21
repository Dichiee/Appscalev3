import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/local/referral_repository.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

/// Honest by design: there is no backend connected in this build, so
/// every local record is genuinely "not yet synced." This screen shows
/// real local counts and says so plainly — it never claims a sync
/// happened that didn't. Once a backend exists, the same counts and
/// layout become live simply by wiring a real API call into "Sync Now."
class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childCount = ChildRepository().getByBarangay(_currentBarangay).length;
    final motherCount = MotherRepository().getAll().where((m) => m.barangay == _currentBarangay).length;
    final referralCount = ReferralRepository().getForBarangay(_currentBarangay).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity, color: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Row(children: [
              InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: AppSpacing.sm),
              Text('Sync Status', style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.statAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.statAmber.withValues(alpha: 0.4))),
                  child: Row(children: [
                    const Icon(Icons.cloud_off_outlined, color: AppColors.statAmber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Not yet connected to a central database. All data below is stored only on this device.', style: AppTextStyles.body.copyWith(fontSize: 12, color: const Color(0xFF633806)))),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Local records', style: AppTextStyles.h2.copyWith(fontSize: 15)),
                const SizedBox(height: AppSpacing.sm),
                _row('Children', childCount),
                _row('Mothers', motherCount),
                _row('Referrals', referralCount),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sync Now — requires backend connection'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 14)),
        Row(children: [
          Text('$count on device', style: AppTextStyles.body.copyWith(fontSize: 12)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)), child: Text('0 synced', style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.textMuted))),
        ]),
      ]),
    );
  }
}