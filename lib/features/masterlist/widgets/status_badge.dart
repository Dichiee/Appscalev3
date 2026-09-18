import 'package:flutter/material.dart';

/// The colored pill used across the app for status labels. Two visual
/// modes: tinted-on-light (used in list rows, over white/off-white cards)
/// and solid-on-dark (used on colored headers like the profile banner),
/// where a low-opacity tint would lose contrast against a saturated
/// background color.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool onDark;

  const StatusBadge({super.key, required this.label, required this.color, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withOpacity(0.95) : color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}