import 'package:hive_flutter/hive_flutter.dart';
import 'app_data_bus.dart';
import 'child_repository.dart';
import 'hive_boxes.dart';
import '../models/child.dart';

/// Enrollment is just "is this child currently in the feeding program,
/// and since when" — keyed directly by childId, since a child only ever
/// belongs to one barangay's program.
class FeedingEnrollmentRepository {
  Box get _box => Hive.box(HiveBoxes.feedingEnrollment);

  Future<void> enroll(String childId) async {
    await _box.put(childId, DateTime.now().toIso8601String());
    AppDataBus.notifyChanged();
  }

  Future<void> unenroll(String childId) async {
    await _box.delete(childId);
    AppDataBus.notifyChanged();
  }

  bool isEnrolled(String childId) => _box.containsKey(childId);

  DateTime? enrolledAt(String childId) {
    final raw = _box.get(childId) as String?;
    return raw == null ? null : DateTime.parse(raw);
  }

  List<Child> getEnrolledChildren(String barangay) {
    return ChildRepository()
        .getByBarangay(barangay)
        .where((c) => c.isActive && isEnrolled(c.id))
        .toList();
  }
}