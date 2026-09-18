import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/mother_visit_repository.dart';
import '../../../data/models/mother.dart';
import '../../../data/models/mother_visit.dart';
import '../../../shared/widgets/detail_row.dart';
import '../../../shared/widgets/section_card.dart';


class InfoTab extends StatelessWidget {
  final Mother mother;
  const InfoTab({super.key, required this.mother});

  @override
  Widget build(BuildContext context) {
    final visits = MotherVisitRepository().getForMother(mother.id);
    final missedCount = visits.where((v) => !v.present).length;
    final MotherVisit? latestConcernVisit = mother.riskStatus == 'At-risk'
        ? visits.firstWhere((v) => v.present && v.observation == 'Signs of concern', orElse: () => visits.first)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: 'Basic Information',
            child: Column(
              children: [
                DetailRow(icon: Icons.badge_outlined, label: 'Full Name', value: mother.fullName),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.cake_outlined, label: 'Age', value: mother.ageLabel),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.event_outlined, label: 'Birth Date', value: _formatDate(mother.birthDate)),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.call_outlined, label: 'Contact no.', value: mother.contactNo.isEmpty ? 'Not provided' : mother.contactNo),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: mother.address),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.groups_outlined, label: 'IP Group', value: mother.belongsToIpGroup ? 'Yes' : 'None'),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.accessibility_new_outlined, label: 'Disability', value: mother.disability),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Breastfeeding practice',
            child: Row(
              children: [
                Expanded(child: Text(mother.breastfeedingPractice, style: AppTextStyles.label.copyWith(fontSize: 15))),
                Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Sourced from the latest counseling visit — update it by logging a new visit, not here.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Visit engagement',
            child: Row(
              children: [
                _StatBlock(label: 'Total visits', value: '${visits.length}'),
                _StatBlock(label: 'Missed', value: '$missedCount'),
                _StatBlock(label: 'Last visit', value: visits.isEmpty ? '—' : _formatDate(visits.first.date)),
              ],
            ),
          ),
          if (mother.riskStatus == 'At-risk' && latestConcernVisit != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Why flagged at-risk', style: AppTextStyles.h2.copyWith(fontSize: 15)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFCEBEB), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Observed by BNS on ${_formatDate(latestConcernVisit.date)}: ${latestConcernVisit.observationNote ?? "no note provided"}',
                style: AppTextStyles.body.copyWith(fontSize: 12, color: const Color(0xFF7A1F1F)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Automatically clears once a future visit shows "Appears well".', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
            ),
            
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.label.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}