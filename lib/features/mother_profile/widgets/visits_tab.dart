import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/mother_visit_repository.dart';
import '../../../data/models/mother.dart';
import '../../../shared/widgets/empty_state.dart';
import 'visit_tile.dart';

class VisitsTab extends StatelessWidget {
  final Mother mother;
  const VisitsTab({super.key, required this.mother});

  @override
  Widget build(BuildContext context) {
    final visits = MotherVisitRepository().getForMother(mother.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visit history', style: AppTextStyles.h1.copyWith(fontSize: 18)),
          const SizedBox(height: AppSpacing.md),
          if (visits.isEmpty)
            const EmptyState(icon: Icons.event_note_outlined, message: 'No counseling visits logged yet. Tap "+ Visit" above to log the first one.')
          else
            ...List.generate(visits.length, (i) => VisitTile(visit: visits[i], isLatest: i == 0)),
        ],
      ),
    );
  }
}