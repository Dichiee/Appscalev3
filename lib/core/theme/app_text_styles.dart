import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Reusable text styles. Screens call AppTextStyles.h1, never TextStyle(...)
/// directly, so font changes and sizing tweaks happen in one place.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}