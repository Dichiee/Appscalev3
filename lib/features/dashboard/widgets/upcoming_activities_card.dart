import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_card.dart';
import '../models/dashboard_models.dart';
import '../../../shared/widgets/empty_state.dart';

class UpcomingActivitiesCard extends StatelessWidget {
  final List<UpcomingActivityData> activities;
  const UpcomingActivitiesCard({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Upcoming Activities',
      child: activities.isEmpty
          ? const EmptyState(icon: Icons.event_available_outlined, message: 'No activities scheduled yet. Once the Schedule feature is built, feeding sessions and weighing days will appear here.')
          : Column(
              children: [
                for (int i = 0; i < activities.length; i++) ...[
                  _ActivityTile(data: activities[i]),
                  if (i != activities.length - 1) const Divider(height: 20, color: AppColors.border),
                ],
              ],
            ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final UpcomingActivityData data;
  const _ActivityTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.month, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), maxLines: 1),
              Text(data.day, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(data.subtitle, style: AppTextStyles.body.copyWith(fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: data.statusColor, borderRadius: BorderRadius.circular(20)),
          child: Text(data.statusLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}