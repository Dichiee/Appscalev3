import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/app_notification.dart';
import '../models/program_schedule.dart';
import 'activity_log_repository.dart';
import 'app_data_bus.dart';
import 'hive_boxes.dart';
import 'notification_repository.dart';

class ProgramScheduleRepository {
  Box get _box => Hive.box(HiveBoxes.programSchedule);

  List<ProgramSchedule> getAllForBarangay(String barangay) {
    final list = _box.values
        .map((e) => ProgramSchedule.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((s) => s.barangay == barangay)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<ProgramSchedule> getUpcoming(String barangay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getAllForBarangay(barangay).where((s) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      return !sDate.isBefore(today);
    }).toList();
  }

  List<ProgramSchedule> getForDate(String barangay, DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return getAllForBarangay(barangay).where((s) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sDate.isAtSameMomentAs(target);
    }).toList();
  }

  Future<void> save(ProgramSchedule schedule) async {
    await _box.put(schedule.id, schedule.toMap());
    await ActivityLogRepository().logActivity(
      type: 'report_generated',
      title: 'Scheduled: ${schedule.title}',
    );
    AppDataBus.notifyChanged();
  }

  /// Processes schedule entries created or updated by RHU Admin / BHW
  /// via the Web Health Portal, storing them locally and dispatching
  /// an in-app notification to the BNS.
  Future<void> receiveWebScheduleUpdate(ProgramSchedule schedule) async {
    await _box.put(schedule.id, schedule.toMap());
    final dateStr =
        '${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}';

    await NotificationRepository().add(AppNotification(
      id: NotificationRepository.generateId(),
      title: 'New Program Schedule Set by RHU',
      message:
          '${schedule.title} (${schedule.programType}) has been scheduled for $dateStr at ${schedule.location} by RHU staff.',
      type: 'general',
      timestamp: DateTime.now(),
    ));

    await ActivityLogRepository().logActivity(
      type: 'report_generated',
      title: 'RHU set schedule for ${schedule.title}',
    );

    AppDataBus.notifyChanged();
  }

  Future<void> seedInitialIfEmpty(String barangay) async {
    if (_box.isNotEmpty) return;

    final now = DateTime.now();
    final samples = [
      ProgramSchedule(
        id: generateId(),
        title: 'Weekly Supplementary Feeding Session',
        programType: 'Feeding',
        date: now.add(const Duration(days: 2)),
        startTime: '08:30 AM',
        endTime: '10:30 AM',
        location: 'Barangay Covered Court',
        targetGroup: 'Enrolled SAM and MAM children',
        notes: 'Bring feeding utensils and attendance cards.',
        barangay: barangay,
        createdBy: 'BNS Mobile',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ProgramSchedule(
        id: generateId(),
        title: 'Garantisadong Pambata: Vitamin A Distribution',
        programType: 'Vitamin A',
        date: now.add(const Duration(days: 5)),
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        location: 'Barangay Health Center',
        targetGroup: 'All infants and children 6–59 months',
        notes: 'Administer Blue (100k IU) for 6-11m and Red (200k IU) for 12-59m.',
        barangay: barangay,
        createdBy: 'RHU Web Admin',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ProgramSchedule(
        id: generateId(),
        title: 'National Deworming Round',
        programType: 'Deworming',
        date: now.add(const Duration(days: 10)),
        startTime: '08:00 AM',
        endTime: '11:30 AM',
        location: 'Barangay Day Care Center',
        targetGroup: 'Children 1–4 years old (12–59 months)',
        notes: 'Albendazole 400mg chewable tablets. Ensure child has eaten breakfast.',
        barangay: barangay,
        createdBy: 'RHU Web Admin',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final s in samples) {
      await _box.put(s.id, s.toMap());
    }
    AppDataBus.notifyChanged();
  }

  static String generateId() => const Uuid().v4();
}
