import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Maps a child's nutrition status string to its display color.
/// Add a new status here (e.g. once MUAC/SAM tracking is built) and
/// every badge and list tile in the app updates automatically.
class ChildStatusMeta {
  ChildStatusMeta._();

  static Color colorFor(String status) {
    switch (status) {
      case 'Normal':
        return AppColors.primaryGreen;
      case 'Underweight':
        return AppColors.statAmber;
      case 'Severely Underweight':
        return AppColors.statRed;
      case 'Overweight':
        return AppColors.statBlue;
      case 'Obese':
        return AppColors.statPurple;
      case 'Stunted':
        return AppColors.statOrange;
      case 'Severely Stunted':
        return AppColors.statRed;
      case 'Not weighed':
        return AppColors.statRed;
      case 'SAM':
        return AppColors.statRed;
      case 'MAM':
        return AppColors.statOrange;
      default:
        return AppColors.textMuted;
      
    }
  }

  static bool needsAttention(String status) => status == 'Not weighed';

  static const allStatuses = [
    'All', 'Normal', 'Underweight', 'Severely Underweight', 'Overweight', 'Obese', 'Stunted', 'Not weighed',
  ];
}