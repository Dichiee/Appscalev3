import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/mother_repository.dart';
import '../../../data/models/child.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/detail_row.dart';
import '../../../shared/utils/app_page_route.dart';
import '../../mother_profile/mother_profile_screen.dart';


class InfoTab extends StatelessWidget {
  final Child child;
  const InfoTab({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final linkedMother = child.guardian.linkedMotherId != null
        ? MotherRepository().getById(child.guardian.linkedMotherId!)
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
                DetailRow(icon: Icons.badge_outlined, label: 'Full Name', value: child.fullName),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.cake_outlined, label: 'Age', value: child.ageLabel),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.wc_outlined, label: 'Gender', value: child.gender),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.event_outlined, label: 'Birth Date', value: _formatDate(child.birthDate)),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: child.address),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.groups_outlined, label: 'IP Group', value: child.belongsToIpGroup ? 'Yes' : 'None'),
                const SizedBox(height: AppSpacing.md),
                DetailRow(icon: Icons.accessibility_new_outlined, label: 'Disability', value: child.disability),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Guardian', style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.guardian.fullName, style: AppTextStyles.label.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text('${child.guardian.relationship} · ${child.guardian.contactNo}', style: AppTextStyles.body.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Monitored mother record', style: AppTextStyles.h2.copyWith(fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          if (linkedMother != null)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(context, appPageRoute(MotherProfileScreen(mother: linkedMother)));
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryGreen)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(linkedMother.fullName, style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.darkGreen)),
                          const SizedBox(height: 2),
                          Text(
                            linkedMother.fullName == child.guardian.fullName ? 'Same as Guardian' : 'Linked mother record',
                            style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.darkGreen),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.darkGreen),
                  ],
                ),
              ),
            )
           else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('Not currently monitored as a beneficiary', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}