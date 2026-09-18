import 'package:hive_flutter/hive_flutter.dart';

/// Single source of truth for Hive box names, so a typo in a box name
/// never silently creates a second box somewhere else in the app.
class HiveBoxes {
  HiveBoxes._();

  static const settings = 'settings_box';
  static const activityLog = 'activity_log_box';
  static const mothers = 'mothers_box';
  static const children = 'children_box';
  static const measurements = 'measurements_box';
  static const motherVisits = 'mother_visits_box';
  static const referrals = 'referrals_box';
  static const feedingEnrollment = 'feeding_enrollment_box';
  static const feedingSchedule = 'feeding_schedule_box';
  static const mealPlans = 'meal_plans_box';
  static const feedingAttendance = 'feeding_attendance_box';
  static const feedingFeedback = 'feeding_feedback_box';
  static const notifications = 'notifications_box';
  static const programSchedule = 'program_schedule_box';
  static const vitaminA = 'vitamin_a_box';
  static const deworming = 'deworming_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settings);
    await Hive.openBox(activityLog);
    await Hive.openBox(mothers);
    await Hive.openBox(children);
    await Hive.openBox(measurements);
    await Hive.openBox(motherVisits);
    await Hive.openBox(referrals);
    await Hive.openBox(feedingEnrollment);
    await Hive.openBox(feedingSchedule);
    await Hive.openBox(mealPlans);
    await Hive.openBox(feedingAttendance);
    await Hive.openBox(feedingFeedback);
    await Hive.openBox(notifications);
    await Hive.openBox(programSchedule);
    await Hive.openBox(vitaminA);
    await Hive.openBox(deworming);
    // Later: openBox<Child>('children_box'), openBox<Mother>('mothers_box'), etc.
  }
}

/// Small typed helper so screens don't sprinkle Hive.box(...) calls everywhere.
class SettingsRepository {
  final _box = Hive.box(HiveBoxes.settings);

  bool get hasSeenOnboarding => _box.get('has_seen_onboarding', defaultValue: false);
  Future<void> setSeenOnboarding() => _box.put('has_seen_onboarding', true);

  bool get rememberMe => _box.get('remember_me', defaultValue: false);
  Future<void> setRememberMe(bool value) => _box.put('remember_me', value);
}