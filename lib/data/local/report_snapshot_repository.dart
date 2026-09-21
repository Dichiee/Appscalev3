import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'hive_boxes.dart';
import '../models/report_snapshot.dart';

/// Every time a consolidation PDF is exported, its computed counts are
/// saved here as a snapshot. The next time that same report type is
/// generated, the previous snapshot becomes the "Old" column — this is
/// how the OLD/NEW paper-form layout works without inventing fake
/// historical data: "Old" genuinely means "the last time this was run."
class ReportSnapshotRepository {
  Box get _box => Hive.box(HiveBoxes.reportSnapshots);

  Future<void> save(ReportSnapshot snapshot) async {
    await _box.put(snapshot.id, snapshot.toMap());
  }

  List<ReportSnapshot> getForType(String reportTypeId, String barangay) {
    final list = _box.values
        .map((e) => ReportSnapshot.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((s) => s.reportTypeId == reportTypeId && s.barangay == barangay)
        .toList();
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  ReportSnapshot? getMostRecent(String reportTypeId, String barangay) {
    final list = getForType(reportTypeId, barangay);
    return list.isEmpty ? null : list.first;
  }

  List<ReportSnapshot> getAllForBarangay(String barangay) {
    final list = _box.values
        .map((e) => ReportSnapshot.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((s) => s.barangay == barangay)
        .toList();
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  static String generateId() => const Uuid().v4();
}