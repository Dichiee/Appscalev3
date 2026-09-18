import '../../../core/theme/app_colors.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/local/feeding_enrollment_repository.dart';
import '../../../data/local/mother_repository.dart';
import '../../masterlist/utils/child_status_meta.dart';
import '../models/dashboard_models.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class DashboardRepository {
  final _childRepo = ChildRepository();
  final _motherRepo = MotherRepository();

  List<StatCardData> getStatCards() {
    final activeChildren = _childRepo.getByBarangay(_currentBarangay).where((c) => c.isActive).toList();
    final activeMothers = _motherRepo.getAll().where((m) => m.barangay == _currentBarangay && m.isActive).toList();

    final childrenThisMonth = activeChildren.where((c) => _isThisMonth(c.createdAt)).length;
    final mothersThisMonth = activeMothers.where((m) => _isThisMonth(m.createdAt)).length;
    // SAM = wasting SAM (weight-for-length), not weight-for-age —
    // the clinically correct definition for this indicator.
    final samCases = activeChildren.where((c) => c.wastingStatus == 'SAM').length;

    final enrolledCount = FeedingEnrollmentRepository().getEnrolledChildren(_currentBarangay).length;

    return [
      StatCardData(
        label: 'Children 0-59 months',
        value: '${activeChildren.length}',
        subtitle: childrenThisMonth > 0 ? '↑ $childrenThisMonth this month' : 'No new records this month',
        accentColor: AppColors.primaryGreen,
      ),
      StatCardData(
        label: 'Lactating Mothers',
        value: '${activeMothers.length}',
        subtitle: mothersThisMonth > 0 ? '↑ $mothersThisMonth this month' : 'No new records this month',
        accentColor: AppColors.statAmber,
      ),
      StatCardData(
        label: 'SAM cases',
        value: '$samCases',
        subtitle: samCases > 0 ? 'Needs intervention' : 'No active SAM cases',
        accentColor: AppColors.statRed,
      ),
      StatCardData(
        label: 'Feeding enrollees',
        value: '$enrolledCount',
        subtitle: enrolledCount > 0 ? '$enrolledCount active in program' : 'No children enrolled yet',
        accentColor: AppColors.statPurple,
      ),
    ];
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Real distribution across the wasting axis, computed from every
  /// active child with at least one recorded measurement. Not-yet-weighed
  /// children are excluded from the percentage base rather than counted
  /// as Normal by default, which would understate real risk.
  List<NutritionStatusItem> getNutritionBreakdown() {
    final weighedChildren = _childRepo
        .getByBarangay(_currentBarangay)
        .where((c) => c.isActive && c.wastingStatus != 'Not weighed')
        .toList();

    if (weighedChildren.isEmpty) return [];

    const order = ['Normal', 'Overweight', 'MAM', 'SAM', 'Obese'];
    final counts = {for (final s in order) s: 0};
    for (final c in weighedChildren) {
      counts[c.wastingStatus] = (counts[c.wastingStatus] ?? 0) + 1;
    }

    final total = weighedChildren.length;
    return order
        .where((s) => counts[s]! > 0)
        .map((s) => NutritionStatusItem(label: s, count: counts[s]!, percent: (counts[s]! / total) * 100, color: ChildStatusMeta.colorFor(s)))
        .toList();
  }

  /// Intentionally empty until the Schedule feature exists — an honest
  /// empty state beats fabricated events.
  List<UpcomingActivityData> getUpcomingActivities() => const [];
}