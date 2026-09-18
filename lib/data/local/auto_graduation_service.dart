import 'activity_log_repository.dart';
import 'child_repository.dart';

/// Runs once per app session (called from Dashboard, since that's where
/// the BNS lands after login). Scans active children for anyone who has
/// crossed 60 months and closes their record automatically — this is the
/// one exit condition that's a computable fact, not a human judgment call,
/// so it's the only one allowed to happen without a manual action.
class AutoGraduationService {
  final _childRepo = ChildRepository();
  final _activityRepo = ActivityLogRepository();

  Future<int> runForBarangay(String barangay) async {
    final candidates = _childRepo.getByBarangay(barangay).where((c) => c.isActive && c.ageInMonths >= 60).toList();
    for (final child in candidates) {
      await _childRepo.update(child.copyWith(isActive: false, inactiveReason: 'Graduated'));
      await _activityRepo.logActivity(type: 'child_graduated', title: '${child.fullName} completed monitoring at 60 months');
    }
    return candidates.length;
  }
}