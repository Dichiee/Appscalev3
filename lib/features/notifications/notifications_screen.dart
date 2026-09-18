import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/notification_repository.dart';
import '../../data/local/referral_repository.dart';
import '../../data/models/app_notification.dart';
import '../../shared/utils/time_ago.dart';
import '../../shared/widgets/empty_state.dart';
import '../referrals/widgets/referral_detail_sheet.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationRepo = NotificationRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: AppDataBus.version,
                builder: (context, value, child) {
                  final unread = notificationRepo.getUnreadCount();
                  return Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Notifications',
                        style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 18),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unread new',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (unread > 0)
                        TextButton(
                          onPressed: () => notificationRepo.markAllAsRead(),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: AppDataBus.version,
                builder: (context, value, child) {
                  final notifications = notificationRepo.getAll();

                  if (notifications.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        icon: Icons.notifications_none_outlined,
                        message: 'No notifications at this time.',
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _NotificationTile(
                        notification: item,
                        onTap: () async {
                          await notificationRepo.markAsRead(item.id);
                          if (item.referralId != null && context.mounted) {
                            final referral = ReferralRepository().getById(item.referralId!);
                            if (referral != null) {
                              ReferralDetailSheet.show(context, referral: referral);
                            }
                          }
                        },
                      );
                    },
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

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'referral_completed':
        return Icons.check_circle_outline;
      case 'referral_in_progress':
        return Icons.sync_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _accentColor {
    switch (notification.type) {
      case 'referral_completed':
        return AppColors.primaryGreen;
      case 'referral_in_progress':
        return AppColors.statBlue;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.lightGreenBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? AppColors.border : AppColors.primaryGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 13,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            timeAgo(notification.timestamp),
                            style: AppTextStyles.body.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.textPrimary.withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                      ),
                      if (notification.referralId != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Tap to view referral details',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 11,
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right, size: 13, color: AppColors.darkGreen),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.statRed,
                      shape: BoxShape.circle,
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
