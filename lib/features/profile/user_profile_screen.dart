import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/mother_repository.dart';

class UserProfileScreen extends StatelessWidget {
  final String bnsName;
  final String barangay;

  const UserProfileScreen({
    super.key,
    this.bnsName = 'Maria Santos',
    this.barangay = 'Barangay Tiguion',
  });

  @override
  Widget build(BuildContext context) {
    final totalChildren = ChildRepository().getAll().where((c) => c.isActive).length;
    final totalMothers = MotherRepository().getAll().where((m) => m.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Worker Profile'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkGreen, AppColors.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    bnsName.isNotEmpty ? bnsName[0] : 'B',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bnsName,
                  style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Barangay Nutrition Scholar (BNS)',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$barangay • Rural Health Unit',
                  style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatTile('Active Children', '$totalChildren', Icons.child_care, AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile('Active Mothers', '$totalMothers', Icons.pregnant_woman, const Color(0xFFD23369)),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Official Information
          Text('Assignment & Station', style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.place_outlined, 'Assigned Barangay', barangay),
                const Divider(height: 1, color: AppColors.border),
                _buildInfoRow(Icons.local_hospital_outlined, 'Health Station', 'Tiguion Barangay Health Station'),
                const Divider(height: 1, color: AppColors.border),
                _buildInfoRow(Icons.phone_outlined, 'Contact Number', '+63 912 345 6789'),
                const Divider(height: 1, color: AppColors.border),
                _buildInfoRow(Icons.badge_outlined, 'Accreditation', 'DOH / NNC Certified BNS'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // System Info
          Text('System Information', style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.offline_bolt_outlined, 'Storage Mode', 'Offline-First (Encrypted Hive)'),
                const Divider(height: 1, color: AppColors.border),
                _buildInfoRow(Icons.info_outline, 'App Version', 'AppScale v3.2.0 (OPT Plus Standards)'),
                const Divider(height: 1, color: AppColors.border),
                _buildInfoRow(Icons.cloud_sync_outlined, 'Sync Protocol', 'Web Portal / RHU Connected'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.statRed,
              side: const BorderSide(color: AppColors.statRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Log Out / Switch Account', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline session preserved for BNS Maria')),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: AppTextStyles.h1.copyWith(fontSize: 20, color: color)),
              Text(title, style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
