import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/referral.dart';
import '../models/app_notification.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';
import 'notification_repository.dart';

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

  Referral? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return Referral.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Simulates / processes incoming updates from the RHU Web Portal (Admin/BHW).
  /// Mobile users cannot edit statuses directly; updates arrive from the web
  /// and trigger an in-app notification when completed or moved in-progress.
  Future<void> receiveWebUpdate({
    required String referralId,
    required String newStatus,
    String? notes,
  }) async {
    final existing = getById(referralId);
    if (existing == null) return;

    final updated = existing.copyWith(
      status: newStatus,
      notes: notes ?? existing.notes,
    );
    await _box.put(updated.id, updated.toMap());

    // Dispatch notification to mobile user
    if (newStatus == 'Completed') {
      await NotificationRepository().add(AppNotification(
        id: NotificationRepository.generateId(),
        title: 'Referral Resolved by RHU',
        message: 'RHU/BHW completed referral for ${updated.beneficiaryName}. Outcome: ${notes?.isNotEmpty == true ? notes : "Referral resolved by RHU."}',
        type: 'referral_completed',
        referralId: updated.id,
        timestamp: DateTime.now(),
      ));
    } else if (newStatus == 'In Progress') {
      await NotificationRepository().add(AppNotification(
        id: NotificationRepository.generateId(),
        title: 'Referral In Progress at RHU',
        message: 'RHU/BHW is currently evaluating ${updated.beneficiaryName}.',
        type: 'referral_in_progress',
        referralId: updated.id,
        timestamp: DateTime.now(),
      ));
    }

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