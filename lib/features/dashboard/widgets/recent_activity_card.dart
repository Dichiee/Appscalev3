import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/activity_log_entry.dart';
import '../../../shared/utils/time_ago.dart';
import '../../../shared/widgets/section_card.dart';
import 'activity_type_meta.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityLogEntry> entries;
  const RecentActivityCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recent Activity',
      child: entries.isEmpty ? const _EmptyState() : _EntryList(entries: entries),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 28),
          const SizedBox(height: 8),
          Text(
            'Nothing recorded yet. Actions you take — adding a child,\nlogging a measurement, creating a referral — will show up here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final List<ActivityLogEntry> entries;
  const _EntryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _EntryTile(entry: entries[i]),
          if (i != entries.length - 1) const Divider(height: 18, color: AppColors.border),
        ],
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final ActivityLogEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = ActivityTypeMeta.colorFor(entry.type);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(ActivityTypeMeta.iconFor(entry.type), size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(entry.title, style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textPrimary))),
        Text(timeAgo(entry.timestamp), style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}