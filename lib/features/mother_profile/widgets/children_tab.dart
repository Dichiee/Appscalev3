import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/beneficiary_link_service.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/models/child.dart';
import '../../../data/models/mother.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../masterlist/utils/child_status_meta.dart';
import '../../masterlist/widgets/status_badge.dart';
import '../../../shared/utils/app_page_route.dart';
import '../../child_profile/child_profile_screen.dart';

class ChildrenTab extends StatelessWidget {
  final Mother mother;
  final VoidCallback onChanged;
  const ChildrenTab({super.key, required this.mother, required this.onChanged});

  Future<void> _confirmUnlink(BuildContext context, Child child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unlink child?'),
        content: Text('${child.fullName} will no longer be linked to ${mother.fullName}\'s profile. Their own record is not affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unlink')),
        ],
      ),
    );
    if (confirmed == true) {
      await BeneficiaryLinkService().unlinkChildFromMother(child: child, mother: mother);
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = ChildRepository().getByIds(mother.linkedChildIds);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Linked children', style: AppTextStyles.h2.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.sm),
          if (children.isEmpty)
            const EmptyState(icon: Icons.child_care_outlined, message: 'No children linked to this mother yet.')
          else
            ...children.map((child) => InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(context, appPageRoute(ChildProfileScreen(child: child))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.fullName, style: AppTextStyles.label.copyWith(fontSize: 14)),
                              Text('${child.ageInMonths} mos · ${child.address}', style: AppTextStyles.body.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        StatusBadge(label: child.nutritionStatus, color: ChildStatusMeta.colorFor(child.nutritionStatus)),
                        IconButton(
                          icon: const Icon(Icons.link_off, size: 18, color: AppColors.textMuted),
                          onPressed: () => _confirmUnlink(context, child),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}