import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Maps an activity "type" string to how it displays. When a future
/// feature (Add Mother, Record Measurement, etc.) starts logging a new
/// type, add one case here — nothing else in the app needs to change.
class ActivityTypeMeta {
  ActivityTypeMeta._();

  static IconData iconFor(String type) {
    switch (type) {
      case 'child_added':
        return Icons.person_add_alt_1_outlined;
      case 'mother_added':
        return Icons.pregnant_woman_outlined;
      case 'measurement_recorded':
        return Icons.monitor_weight_outlined;
      case 'referral_created':
        return Icons.local_hospital_outlined;
      case 'report_generated':
        return Icons.description_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  static Color colorFor(String type) {
    switch (type) {
      case 'child_added':
      case 'mother_added':
        return AppColors.primaryGreen;
      case 'measurement_recorded':
        return AppColors.statBlue;
      case 'referral_created':
        return AppColors.statRed;
      case 'report_generated':
        return AppColors.statPurple;
      default:
        return AppColors.textMuted;
    }
  }
}