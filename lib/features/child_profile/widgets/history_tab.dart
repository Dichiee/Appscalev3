import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/measurement_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import 'measurement_tile.dart';

class HistoryTab extends StatelessWidget {
  final String childId;
  const HistoryTab({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final measurements = MeasurementRepository().getForChild(childId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Measurement History', style: AppTextStyles.h1.copyWith(fontSize: 18)),
          const SizedBox(height: AppSpacing.md),
          if (measurements.isEmpty)
            const EmptyState(icon: Icons.timeline_outlined, message: 'No measurements recorded yet. Tap "+ Measure" to log the first one.')
          else
            ...List.generate(
              measurements.length,
              (i) => MeasurementTile(measurement: measurements[i], isLatest: i == 0),
            ),
        ],
      ),
    );
  }
}