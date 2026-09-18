import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/app_notification.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';

class NotificationRepository {
  Box get _box => Hive.box(HiveBoxes.notifications);

  List<AppNotification> getAll() {
    final list = _box.values
        .map((n) => AppNotification.fromMap(Map<String, dynamic>.from(n as Map)))
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int getUnreadCount() => getAll().where((n) => !n.isRead).length;

  Future<void> add(AppNotification notification) async {
    await _box.put(notification.id, notification.toMap());
    AppDataBus.notifyChanged();
  }

  Future<void> markAsRead(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      final notif = AppNotification.fromMap(Map<String, dynamic>.from(raw as Map));
      if (!notif.isRead) {
        await _box.put(id, notif.copyWith(isRead: true).toMap());
        AppDataBus.notifyChanged();
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (final raw in _box.values) {
      final notif = AppNotification.fromMap(Map<String, dynamic>.from(raw as Map));
      if (!notif.isRead) {
        await _box.put(notif.id, notif.copyWith(isRead: true).toMap());
      }
    }
    AppDataBus.notifyChanged();
  }

  /// Seeds realistic initial notifications if the box is empty so the BNS
  /// can see how web-driven referral completions look in the app.
  Future<void> seedInitialIfEmpty() async {
    if (_box.isNotEmpty) return;

    final samples = [
      AppNotification(
        id: generateId(),
        title: 'Referral Resolved by RHU',
        message: 'RHU completed referral for Baby Juan Cruz (SAM). Outcome: RUTF supply provided, scheduled for weekly follow-up weighing.',
        type: 'referral_completed',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: generateId(),
        title: 'Referral Evaluated by BHW',
        message: 'Barangay Health Worker acknowledged referral for Maria Santos. Status is now In Progress at RHU.',
        type: 'referral_in_progress',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
      AppNotification(
        id: generateId(),
        title: 'Monthly OPT Plus Reminder',
        message: 'Operation Timbang Plus schedule for Barangay Tiguion has been set by the RHU Admin.',
        type: 'general',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    for (final s in samples) {
      await _box.put(s.id, s.toMap());
    }
    AppDataBus.notifyChanged();
  }

  static String generateId() => const Uuid().v4();
}
