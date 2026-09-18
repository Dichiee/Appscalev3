import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_gradient_header.dart';

class DashboardHeader extends StatelessWidget {
  final String bnsName;
  final String barangayName;
  final int pendingSyncCount;
  final int unreadNotificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onSyncTap;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    required this.bnsName,
    required this.barangayName,
    required this.pendingSyncCount,
    this.unreadNotificationCount = 0,
    required this.onNotificationTap,
    required this.onSyncTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppGradientHeader(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome!', style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 15)),
                Text(bnsName, style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 25)),
                Text(barangayName, style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSyncTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('$pendingSyncCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                ),
                if (unreadNotificationCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      alignment: Alignment.center,
                      child: Text(
                        unreadNotificationCount > 9 ? '9+' : '$unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                bnsName.isNotEmpty ? bnsName[0] : 'B',
                style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}