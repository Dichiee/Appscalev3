import 'child_repository.dart';
import 'feeding_enrollment_repository.dart';
import '../models/child.dart';

/// Suggests, never auto-enrolls. A malnourished child appears here so a
/// BNS can decide to add them — the decision always stays a deliberate
/// action, same principle as the referral "needs attention" list.
class FeedingSuggestionService {
  final _childRepo = ChildRepository();
  final _enrollmentRepo = FeedingEnrollmentRepository();

  bool _isMalnourished(Child c) =>
      c.nutritionStatus == 'Underweight' ||
      c.nutritionStatus == 'Severely Underweight' ||
      c.wastingStatus == 'MAM' ||
      c.wastingStatus == 'SAM';

  List<Child> getSuggested(String barangay) => _childRepo
      .getByBarangay(barangay)
      .where((c) => c.isActive && _isMalnourished(c) && !_enrollmentRepo.isEnrolled(c.id))
      .toList();
}