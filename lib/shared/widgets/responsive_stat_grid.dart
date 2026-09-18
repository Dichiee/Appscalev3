import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/dashboard/models/dashboard_models.dart';
import '../../features/dashboard/widgets/stat_card.dart';

/// Lays out stat cards two-per-row using IntrinsicHeight, so both cards
/// in a row always match the taller one's natural height — never a fixed
/// forced ratio. This is what makes the grid immune to font-scaling and
/// device-density overflow bugs. Works for any even or odd item count.
class ResponsiveStatGrid extends StatelessWidget {
  final List<StatCardData> items;
  final List<VoidCallback?>? onTaps;
  const ResponsiveStatGrid({super.key, required this.items, this.onTaps});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final hasSecond = i + 1 < items.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: StatCard(data: items[i], onTap: onTaps != null && i < onTaps!.length ? onTaps![i] : null)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: hasSecond ? StatCard(data: items[i + 1], onTap: onTaps != null && (i + 1) < onTaps!.length ? onTaps![i + 1] : null) : const SizedBox()),
            ],
          ),
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: AppSpacing.md));
    }
    return Column(children: rows);
  }
}