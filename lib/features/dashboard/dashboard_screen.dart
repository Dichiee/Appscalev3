import 'package:flutter/material.dart';
import '../../data/local/activity_log_repository.dart';
import 'data/dashboard_repository.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/nutrition_status_card.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/upcoming_activities_card.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/responsive_stat_grid.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/auto_graduation_service.dart';
import '../referrals/referrals_overview_screen.dart';
import '../../shared/utils/app_page_route.dart';

import '../../data/local/notification_repository.dart';
import '../notifications/notifications_screen.dart';

import '../masterlist/widgets/masterlist_header.dart';

/// The Home tab's content only. MainShell provides the Scaffold,
/// bottom nav, and FAB — this widget just returns what goes inside.
class DashboardBody extends StatefulWidget {
  final void Function(MasterlistCategory category)? onNavigateToMasterlist;
  const DashboardBody({super.key, this.onNavigateToMasterlist});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  final _dashboardRepo = DashboardRepository();
  final _activityRepo = ActivityLogRepository();
  final _notificationRepo = NotificationRepository();

  @override
  void initState() {
    super.initState();
    _notificationRepo.seedInitialIfEmpty();
    AutoGraduationService().runForBarangay('Tiguion'); // TODO: pull from session
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, value, childWidget) {
        final stats = _dashboardRepo.getStatCards();
        final nutrition = _dashboardRepo.getNutritionBreakdown();
        final upcoming = _dashboardRepo.getUpcomingActivities();
        final recent = _activityRepo.getRecent();
        final unreadNotifs = _notificationRepo.getUnreadCount();

        return RefreshIndicator(
          onRefresh: () async => AppDataBus.notifyChanged(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DashboardHeader(
                bnsName: 'BNS Maria',
                barangayName: 'Barangay Tiguion',
                pendingSyncCount: 12,
                unreadNotificationCount: unreadNotifs,
                onSyncTap: () {},
                onNotificationTap: () => Navigator.push(context, appPageRoute(const NotificationsScreen())),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveStatGrid(
                      items: stats,
                      onTaps: [
                        () => widget.onNavigateToMasterlist?.call(MasterlistCategory.children),
                        () => widget.onNavigateToMasterlist?.call(MasterlistCategory.mothers),
                        () => Navigator.push(context, appPageRoute(const ReferralsOverviewScreen())),
                        null,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    NutritionStatusCard(items: nutrition),
                    const SizedBox(height: AppSpacing.lg),
                    UpcomingActivitiesCard(activities: upcoming),
                    const SizedBox(height: AppSpacing.lg),
                    RecentActivityCard(entries: recent),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}