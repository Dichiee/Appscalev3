import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/mother_visit.dart';
import '../../masterlist/widgets/status_badge.dart';

class VisitTile extends StatelessWidget {
  final MotherVisit visit;
  final bool isLatest;

  const VisitTile({super.key, required this.visit, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    final statusLabel = !visit.present ? 'Missed' : (visit.observation ?? '—');
    final accentColor = !visit.present
        ? AppColors.textMuted
        : (visit.observation == 'Signs of concern' ? AppColors.statRed : AppColors.primaryGreen);

    final note = !visit.present
        ? 'No show · rescheduled by BNS'
        : [
            if (visit.observationNote != null) visit.observationNote,
            if (visit.breastfeedingPractice != null) '${visit.breastfeedingPractice} confirmed',
            if (visit.hasMedicalConcern && visit.concernNote != null) 'Concern: ${visit.concernNote}',
          ].whereType<String>().join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, decoration: BoxDecoration(color: accentColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_formatDate(visit.date), style: AppTextStyles.label.copyWith(fontSize: 14)),
                        if (isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(20)),
                            child: Text('Latest', style: TextStyle(color: AppColors.darkGreen, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                        const Spacer(),
                        StatusBadge(label: statusLabel, color: accentColor),
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),
                      Text(note, style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}