import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/local/measurement_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import 'trend_chart_card.dart';

class ChartsTab extends StatelessWidget {
  final String childId;
  const ChartsTab({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final measurements = MeasurementRepository().getForChildAscending(childId);

    if (measurements.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(icon: Icons.show_chart, message: 'No trend data yet. Charts will appear once measurements are recorded.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TrendChartCard(title: 'Weight Trend (kg)', color: AppColors.statBlue, measurementsAscending: measurements, valueOf: (m) => m.weightKg),
          const SizedBox(height: AppSpacing.lg),
          TrendChartCard(title: 'Height Trend (cm)', color: AppColors.statOrange, measurementsAscending: measurements, valueOf: (m) => m.heightCm),
          const SizedBox(height: AppSpacing.lg),
          TrendChartCard(title: 'MUAC Trend (cm)', color: const Color(0xFFCC2E6D), measurementsAscending: measurements, valueOf: (m) => m.muacCm),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}