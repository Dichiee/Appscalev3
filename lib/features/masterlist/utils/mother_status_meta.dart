import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MotherStatusMeta {
  MotherStatusMeta._();

  static Color colorFor(String status) {
    switch (status) {
      case 'Normal':
        return AppColors.primaryGreen;
      case 'At-risk':
        return AppColors.statRed;
      default:
        return AppColors.textMuted;
    }
  }
}