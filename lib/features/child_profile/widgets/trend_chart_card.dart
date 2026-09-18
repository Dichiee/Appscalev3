import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/measurement.dart';

/// One reusable line chart card — weight, height, and MUAC trends all
/// use this same widget with a different color and value selector,
/// instead of three near-identical chart implementations.
class TrendChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<Measurement> measurementsAscending;
  final double? Function(Measurement) valueOf;

  const TrendChartCard({
    super.key,
    required this.title,
    required this.color,
    required this.measurementsAscending,
    required this.valueOf,
  });

  static const _monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < measurementsAscending.length; i++) {
      final v = valueOf(measurementsAscending[i]);
      if (v == null) continue;
      spots.add(FlSpot(i.toDouble(), v));
    }

    if (spots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15, color: color)),
            const SizedBox(height: 16),
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text('No $title data recorded yet.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
            ),
          ],
        ),
      );
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY == 0) ? 2.0 : ((maxY - minY) * 0.2).clamp(0.5, 5.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h2.copyWith(fontSize: 15, color: color)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: spots.length == 1 ? -0.5 : 0,
                maxX: spots.length == 1 ? 0.5 : (measurementsAscending.length - 1).toDouble(),
                minY: (minY - yPadding).clamp(0.0, double.infinity),
                maxY: maxY + yPadding,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: _yInterval(spots)),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 34, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10, color: AppColors.textMuted))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= measurementsAscending.length) return const SizedBox.shrink();
                        final month = measurementsAscending[index].date.month;
                        return Padding(padding: const EdgeInsets.only(top: 4), child: Text(_monthLabels[month - 1], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: spots.length > 1,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (spot, pct, bar, index) => FlDotCirclePainter(radius: 4, color: color, strokeWidth: 0)),
                    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _yInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final values = spots.map((s) => s.y);
    final range = values.reduce((a, b) => a > b ? a : b) - values.reduce((a, b) => a < b ? a : b);
    if (range <= 0) return 1;
    return (range / 4).clamp(0.5, double.infinity);
  }
}