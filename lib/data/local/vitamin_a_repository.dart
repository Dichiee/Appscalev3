import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/vitamin_a_record.dart';
import 'activity_log_repository.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

class VitaminARepository {
  Box get _box => Hive.box(HiveBoxes.vitaminA);

  List<VitaminARecord> getAllForBarangay(String barangay) {
    final list = _box.values
        .map((e) => VitaminARecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.barangay == barangay)
        .toList();
    list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
    return list;
  }

  List<VitaminARecord> getByChildId(String childId) {
    final list = _box.values
        .map((e) => VitaminARecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.childId == childId)
        .toList();
    list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
    return list;
  }

  VitaminARecord? getLatestForChild(String childId) {
    final list = getByChildId(childId);
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> save(VitaminARecord record) async {
    await _box.put(record.id, record.toMap());
    await ActivityLogRepository().logActivity(
      type: 'measurement_added',
      title: 'Administered Vit A: ${record.childName} (${record.dosage})',
    );
    AppDataBus.notifyChanged();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    AppDataBus.notifyChanged();
  }

  static String determineRecommendedDosage(int ageInMonths) {
    if (ageInMonths < 6) {
      return 'Not Eligible (<6 mos)';
    } else if (ageInMonths <= 11) {
      return '100,000 IU (Blue)';
    } else if (ageInMonths <= 59) {
      return '200,000 IU (Red)';
    } else {
      return 'Exceeds Target Age (>59 mos)';
    }
  }

  static String determineDefaultDoseType(int ageInMonths) {
    if (ageInMonths < 6) {
      return 'Under Age';
    } else if (ageInMonths <= 11) {
      return 'Routine (6-11 mos)';
    } else {
      return 'Routine (12-59 mos)';
    }
  }

  void seedInitialIfEmpty(String barangay) {
    if (_box.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = [
      VitaminARecord(
        id: const Uuid().v4(),
        childId: 'c1',
        childName: 'Juan Dela Cruz Jr.',
        barangay: barangay,
        ageInMonths: 8,
        dateGiven: now.subtract(const Duration(days: 14)),
        dosage: '100,000 IU (Blue)',
        doseType: 'Routine (6-11 mos)',
        administeredBy: 'BNS Maria',
        remarks: 'Normal, no adverse reaction',
        nextDueDate: now.add(const Duration(days: 166)),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      VitaminARecord(
        id: const Uuid().v4(),
        childId: 'c2',
        childName: 'Maria Santos',
        barangay: barangay,
        ageInMonths: 24,
        dateGiven: now.subtract(const Duration(days: 30)),
        dosage: '200,000 IU (Red)',
        doseType: 'Routine (12-59 mos)',
        administeredBy: 'BNS Maria',
        remarks: 'Administered during Garantisadong Pambata',
        nextDueDate: now.add(const Duration(days: 150)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      VitaminARecord(
        id: const Uuid().v4(),
        childId: 'c3',
        childName: 'Baby Boy Reyes',
        barangay: barangay,
        ageInMonths: 18,
        dateGiven: now.subtract(const Duration(days: 45)),
        dosage: '200,000 IU (Red)',
        doseType: 'Routine (12-59 mos)',
        administeredBy: 'BNS Maria',
        remarks: 'Given at Barangay Health Center',
        nextDueDate: now.add(const Duration(days: 135)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];

    for (final r in seeds) {
      _box.put(r.id, r.toMap());
    }
  }
}
