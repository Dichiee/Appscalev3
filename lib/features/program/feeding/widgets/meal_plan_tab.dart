import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/local/feeding_feedback_repository.dart';
import '../../../../data/local/meal_plan_repository.dart';
import '../../../../shared/utils/app_page_route.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../add_feeding_feedback_screen.dart';
import '../update_meal_plan_screen.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class MealPlanTab extends StatelessWidget {
  const MealPlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final active = MealPlanRepository().getActiveForDate(_currentBarangay, DateTime.now());
    final history = MealPlanRepository().getAllForBarangay(_currentBarangay);
    final feedback = FeedingFeedbackRepository().getForBarangay(_currentBarangay);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Current Meal Plan', style: AppTextStyles.h2.copyWith(fontSize: 16)),
            InkWell(
              onTap: () => Navigator.push(context, appPageRoute(const UpdateMealPlanScreen())),
              child: Row(children: [
                const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text('Update Meal Plan', style: AppTextStyles.body.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          if (active == null)
            const EmptyState(icon: Icons.restaurant_menu_outlined, message: 'No meal plan set yet.')
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Effective since ${_formatDate(active.effectiveFrom)}', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.darkGreen)),
                const SizedBox(height: 8),
                ...active.foodItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.darkGreen),
                        const SizedBox(width: 8),
                        Text(item, style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textPrimary)),
                      ]),
                    )),
              ]),
            ),
          if (history.length > 1) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Meal Plan History', style: AppTextStyles.h2.copyWith(fontSize: 14)),
            const SizedBox(height: AppSpacing.sm),
            ...history.skip(1).take(3).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${_formatDate(p.effectiveFrom)} – ${p.effectiveTo == null ? 'present' : _formatDate(p.effectiveTo!)}: ${p.itemsSummary}',
                    style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
                )),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Session Feedback', style: AppTextStyles.h2.copyWith(fontSize: 16)),
            InkWell(
              onTap: () => Navigator.push(context, appPageRoute(const AddFeedingFeedbackScreen())),
              child: Row(children: [
                const Icon(Icons.add_circle_outline, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Text('Add note', style: AppTextStyles.body.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: 4),
          Text('Field observations, not a computed effectiveness score.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          if (feedback.isEmpty)
            const EmptyState(icon: Icons.rate_review_outlined, message: 'No feedback logged yet.')
          else
            ...feedback.map((f) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(_formatDate(f.date), style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
                      if (f.tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: f.tag == 'Went well' ? AppColors.lightGreenBg : const Color(0xFFFAEEDA), borderRadius: BorderRadius.circular(20)),
                          child: Text(f.tag!, style: TextStyle(color: f.tag == 'Went well' ? AppColors.darkGreen : const Color(0xFF633806), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 6),
                    Text(f.note, style: AppTextStyles.body.copyWith(fontSize: 12)),
                  ]),
                )),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}