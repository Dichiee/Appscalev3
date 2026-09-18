import 'package:hive_flutter/hive_flutter.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';
import '../models/feeding_schedule.dart';

/// One schedule per barangay — setting a new one overwrites the old,
/// since a barangay realistically runs one feeding pattern at a time.
class FeedingScheduleRepository {
  Box get _box => Hive.box(HiveBoxes.feedingSchedule);

  Future<void> save(FeedingSchedule schedule) async {
    await _box.put(schedule.barangay, schedule.toMap());
    AppDataBus.notifyChanged();
  }

  FeedingSchedule? get(String barangay) {
    final raw = _box.get(barangay);
    return raw == null ? null : FeedingSchedule.fromMap(Map<String, dynamic>.from(raw as Map));
  }
}