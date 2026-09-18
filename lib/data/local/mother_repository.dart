import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/mother.dart';
import 'hive_boxes.dart';
import 'app_data_bus.dart';

class MotherRepository {
  Box get _box => Hive.box(HiveBoxes.mothers);

  Future<Mother> add(Mother mother) async {
    await _box.put(mother.id, mother.toMap());
    AppDataBus.notifyChanged();
    return mother;
  }

  Mother? getById(String id) {
    final map = _box.get(id);
    return map == null ? null : Mother.fromMap(map as Map);
  }

  List<Mother> getAll() =>
      _box.values.map((m) => Mother.fromMap(m as Map)).toList();

  Future<void> update(Mother mother) async {
    await _box.put(mother.id, mother.toMap());
    AppDataBus.notifyChanged();
  }

  /// Used by the Link Mother search field — filters by barangay first,
  /// then by name, and caps results so the list never overwhelms the screen.
  List<Mother> search(String query, {required String barangay, int limit = 6}) {
    final lower = query.trim().toLowerCase();
    final results = getAll().where((m) {
      final matchesBarangay = m.barangay.toLowerCase() == barangay.toLowerCase();
      final matchesName = lower.isEmpty || m.fullName.toLowerCase().contains(lower);
      return matchesBarangay && matchesName;
    }).toList();
    return results.take(limit).toList();
  }

  static String generateId() => const Uuid().v4();

    List<Mother> getFiltered({
    required String barangay,
    required bool activeOnly,
    String query = '',
  }) {
    final lower = query.trim().toLowerCase();
    return getAll().where((m) {
      final matchesBarangay = m.barangay.toLowerCase() == barangay.toLowerCase();
      final matchesActive = m.isActive == activeOnly;
      final matchesQuery = lower.isEmpty || m.fullName.toLowerCase().contains(lower);
      return matchesBarangay && matchesActive && matchesQuery;
    }).toList();
  }

  int countActive(String barangay) => getAll().where((m) => m.barangay == barangay && m.isActive).length;
  int countInactive(String barangay) => getAll().where((m) => m.barangay == barangay && !m.isActive).length;
}