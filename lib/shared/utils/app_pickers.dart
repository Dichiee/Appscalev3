import 'package:flutter/material.dart';

/// Use this instead of Flutter's bare showDatePicker anywhere in the app.
///
/// Why this exists: Flutter's Material date/time pickers apply their own
/// internal text-scale clamp on top of whatever TextScaler they inherit.
/// Since main.dart already clamps text scaling app-wide (see MaterialApp's
/// builder), handing that already-clamped scaler into the picker causes
/// a double-clamp that can crash with "maxScale > minScale is not true"
/// on devices with large accessibility font settings.
///
/// The fix: reset MediaQuery's textScaler to a single plain, safe value
/// right at the picker's boundary, via its own `builder`. The rest of the
/// app keeps the global clamp untouched — this only affects the picker's
/// internal subtree.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      final safeScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(safeScale.clamp(0.9, 1.25)),
        ),
        child: child!,
      );
    },
  );
}