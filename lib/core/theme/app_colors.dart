import 'package:flutter/material.dart';

/// Central color palette. Never hardcode a Color(0xFF...) in a screen —
/// add it here once, reference it everywhere. Makes rebranding or
/// dark-mode support later a one-file change instead of a find-and-replace.
class AppColors {
  AppColors._();

  static const primaryGreen = Color(0xFF5A8F29);
  static const darkGreen = Color(0xFF3E7C1B);
  static const lightGreenBg = Color(0xFFEAF3DE);

  static const background = Color(0xFFFAF9F5);
  static const surface = Colors.white;

  static const textPrimary = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFF9A9A9A);

  static const border = Color(0xFFE0E0E0);
  static const borderFocused = primaryGreen;

  static const dotInactive = Color(0xFFD9D9D9);

  static const statAmber = Color(0xFFEFA727);
  static const statRed = Color(0xFFE94B4B);
  static const statPurple = Color(0xFF6C4BE9);
  static const statBlue = Color(0xFF2E7FE0);
  static const statOrange = Color(0xFFEF9F27);
}