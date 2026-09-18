import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/app_data_bus.dart';
import 'widgets/attendance_tab.dart';
import 'widgets/feeding_header.dart';
import 'widgets/feeding_tab_bar.dart';
import 'widgets/meal_plan_tab.dart';
import 'widgets/overview_tab.dart';
import 'widgets/weighing_tab.dart';

class FeedingProgramScreen extends StatefulWidget {
  const FeedingProgramScreen({super.key});

  @override
  State<FeedingProgramScreen> createState() => _FeedingProgramScreenState();
}

class _FeedingProgramScreenState extends State<FeedingProgramScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: AppDataBus.version,
          builder: (context, _, __) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(children: [
                    InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back)),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Feeding Program', style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(children: const [FeedingHeader(), SizedBox(height: AppSpacing.md)]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: FeedingTabBar(currentIndex: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    // NOT const — these StatelessWidgets must rebuild every
                    // time AppDataBus fires, or changes won't show until
                    // the screen is left and re-entered.
                    children: [
                      const OverviewTab(),
                      const AttendanceTab(),
                      const MealPlanTab(),
                      const WeighingTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}