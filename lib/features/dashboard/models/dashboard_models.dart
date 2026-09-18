import 'package:flutter/material.dart';

class StatCardData {
  final String label;
  final String value;
  final String subtitle;
  final Color accentColor;

  const StatCardData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });
}

class NutritionStatusItem {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const NutritionStatusItem({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });
}

class UpcomingActivityData {
  final String month;
  final String day;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;

  const UpcomingActivityData({
    required this.month,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
  });
}