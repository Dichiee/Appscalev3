import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';
import '../models/report_signatory.dart';

/// One signatory set per barangay — set once, printed automatically on
/// every report from then on, exactly matching how the paper forms work.
class ReportSignatoryRepository {
  Box get _box => Hive.box(HiveBoxes.reportSignatories);

  Future<void> save(ReportSignatory signatory) async {
    await _box.put(signatory.barangay, signatory.toMap());
  }

  ReportSignatory? get(String barangay) {
    final raw = _box.get(barangay);
    return raw == null ? null : ReportSignatory.fromMap(Map<String, dynamic>.from(raw as Map));
  }
}