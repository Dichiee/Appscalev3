import 'package:hive_flutter/hive_flutter.dart';
import 'activity_log_entry.dart';
import 'hive_boxes.dart';
import 'app_data_bus.dart';

/// Every feature that changes data — Add Child, Record Measurement,
/// Create Referral, Generate Report, etc. — should call
/// ActivityLogRepository().logActivity(...) right when it saves.
/// The Dashboard only ever reads from here; it never needs to know
/// which screen produced the entry. This is what makes Recent Activity
/// real instead of hardcoded.
class ActivityLogRepository {
  Box get _box => Hive.box(HiveBoxes.activityLog);

  Future<void> logActivity({required String type, required String title}) async {
    await _box.add(
      ActivityLogEntry(type: type, title: title, timestamp: DateTime.now()).toMap(),
    );
    AppDataBus.notifyChanged();
  }

  List<ActivityLogEntry> getRecent({int limit = 5}) {
    final entries = _box.values
        .map((e) => ActivityLogEntry.fromMap(e as Map))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.take(limit).toList();
  }
}