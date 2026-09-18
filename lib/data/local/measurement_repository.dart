import 'package:hive_flutter/hive_flutter.dart';
import '../models/measurement.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

/// Measurements are stored as a list per child, keyed by childId.
/// This keeps a child's full history in one read instead of scanning
/// a flat box for matches, which matters once histories grow long.
class MeasurementRepository {
  Box get _box => Hive.box(HiveBoxes.measurements);

  /// Returns newest-first — matches how History and the header's
  /// "Latest" badge expect the data.
  List<Measurement> getForChild(String childId) {
    final raw = _box.get(childId) as List?;
    if (raw == null) return [];
    final list = raw
        .map((e) => Measurement.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Charts read oldest-first, since a trend line reads left-to-right in time.
  List<Measurement> getForChildAscending(String childId) =>
      getForChild(childId).reversed.toList();

  Future<void> addMeasurement(String childId, Measurement measurement) async {
    final current = (_box.get(childId) as List?) ?? [];
    await _box.put(childId, [...current, measurement.toMap()]);
    AppDataBus.notifyChanged();
  }
}