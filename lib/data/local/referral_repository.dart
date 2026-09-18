import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/referral.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

class ReferralRepository {
  Box get _box => Hive.box(HiveBoxes.referrals);

  Future<Referral> add(Referral referral) async {
    await _box.put(referral.id, referral.toMap());
    AppDataBus.notifyChanged();
    return referral;
  }

  Future<void> update(Referral referral) async {
    await _box.put(referral.id, referral.toMap());
    AppDataBus.notifyChanged();
  }

  List<Referral> getAll() => _box.values.map((r) => Referral.fromMap(Map<String, dynamic>.from(r as Map))).toList();

  List<Referral> getForBeneficiary(String beneficiaryId) {
    final list = getAll().where((r) => r.beneficiaryId == beneficiaryId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Barangay-wide view for the Dashboard entry point — pending and
  /// in-progress cases surface first, since those are what a BNS
  /// actually needs to act on.
  List<Referral> getForBarangay(String barangay) {
    final list = getAll().where((r) => r.barangay == barangay).toList();
    list.sort((a, b) {
      const order = {'Pending': 0, 'In Progress': 1, 'Completed': 2, 'Cancelled': 3};
      final statusCompare = (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
      if (statusCompare != 0) return statusCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  int countOpenForBarangay(String barangay) =>
      getAll().where((r) => r.barangay == barangay && (r.status == 'Pending' || r.status == 'In Progress')).length;

  static String generateId() => const Uuid().v4();
}