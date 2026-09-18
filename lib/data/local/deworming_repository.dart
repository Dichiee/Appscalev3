import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/deworming_record.dart';
import 'activity_log_repository.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

class DewormingRepository {
  Box get _box => Hive.box(HiveBoxes.deworming);

  List<DewormingRecord> getAllForBarangay(String barangay) {
    final list = _box.values
        .map((e) => DewormingRecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.barangay == barangay)
        .toList();
    list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
    return list;
  }

  List<DewormingRecord> getByChildId(String childId) {
    final list = _box.values
        .map((e) => DewormingRecord.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.childId == childId)
        .toList();
    list.sort((a, b) => b.dateGiven.compareTo(a.dateGiven));
    return list;
  }

  DewormingRecord? getLatestForChild(String childId) {
    final list = getByChildId(childId);
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> save(DewormingRecord record) async {
    await _box.put(record.id, record.toMap());
    await ActivityLogRepository().logActivity(
      type: 'measurement_added',
      title: 'Dewormed: ${record.childName} (${record.drugName})',
    );
    AppDataBus.notifyChanged();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    AppDataBus.notifyChanged();
  }

  static bool isEligible(int ageInMonths) {
    // Under Philippine DOH Deworming Guidelines, routine deworming is for children 12-59 months (1-4 yrs)
    return ageInMonths >= 12 && ageInMonths <= 59;
  }

  static String currentNationalRound() {
    final month = DateTime.now().month;
    return month <= 6 ? '1st Round (Jan - Jun)' : '2nd Round (Jul - Dec)';
  }

  void seedInitialIfEmpty(String barangay) {
    if (_box.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = [
      DewormingRecord(
        id: const Uuid().v4(),
        childId: 'c2',
        childName: 'Maria Santos',
        barangay: barangay,
        ageInMonths: 24,
        dateGiven: now.subtract(const Duration(days: 20)),
        drugName: 'Albendazole 400mg',
        round: currentNationalRound(),
        adverseEvents: 'None',
        administeredBy: 'BNS Maria',
        remarks: 'Administered under direct observation',
        nextDueDate: now.add(const Duration(days: 160)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      DewormingRecord(
        id: const Uuid().v4(),
        childId: 'c3',
        childName: 'Baby Boy Reyes',
        barangay: barangay,
        ageInMonths: 18,
        dateGiven: now.subtract(const Duration(days: 35)),
        drugName: 'Albendazole 400mg',
        round: currentNationalRound(),
        adverseEvents: 'None',
        administeredBy: 'BNS Maria',
        remarks: 'Taken with water after meal',
        nextDueDate: now.add(const Duration(days: 145)),
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ];

    for (final r in seeds) {
      _box.put(r.id, r.toMap());
    }
  }
}
