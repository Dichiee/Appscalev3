import 'package:hive_flutter/hive_flutter.dart';
import '../models/mother_visit.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

/// Visits stored as a list per mother, keyed by motherId — same pattern
/// as MeasurementRepository. Newest-first, since that's what both the
/// Visits tab and MotherRiskService need.
class MotherVisitRepository {
  Box get _box => Hive.box(HiveBoxes.motherVisits);

  List<MotherVisit> getForMother(String motherId) {
    final raw = _box.get(motherId) as List?;
    if (raw == null) return [];
    final list = raw.map((e) => MotherVisit.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> addVisit(String motherId, MotherVisit visit) async {
    final current = (_box.get(motherId) as List?) ?? [];
    await _box.put(motherId, [...current, visit.toMap()]);
    AppDataBus.notifyChanged();
  }
}