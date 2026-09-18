import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/meal_plan_repository.dart';
import '../../../data/models/meal_plan.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/form_action_buttons.dart';
import '../../../shared/widgets/form_section_card.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class UpdateMealPlanScreen extends StatefulWidget {
  const UpdateMealPlanScreen({super.key});

  @override
  State<UpdateMealPlanScreen> createState() => _UpdateMealPlanScreenState();
}

class _UpdateMealPlanScreenState extends State<UpdateMealPlanScreen> {
  final _mealInputController = TextEditingController();
  final List<String> _mealItems = [];
  DateTime? _effectiveFrom = DateTime.now();
  bool _isSaving = false;

  void _addItem() {
    final text = _mealInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _mealItems.add(text);
      _mealInputController.clear();
    });
  }

  bool get _isFormValid => _mealItems.isNotEmpty && _effectiveFrom != null;

  Future<void> _save() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one food item and a start date')));
      return;
    }
    setState(() => _isSaving = true);
    await MealPlanRepository().addAndCloseOthers(MealPlan(
      id: MealPlanRepository.generateId(),
      foodItems: _mealItems,
      effectiveFrom: _effectiveFrom!,
      effectiveTo: null, // stays active until the next plan replaces it
      barangay: _currentBarangay,
      createdAt: DateTime.now(),
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity, color: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Row(children: [
              InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: AppSpacing.sm),
              Text('Update Meal Plan', style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 17)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('This menu stays active until you update it again — no need to re-enter it daily.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.md),
                FormSectionCard(title: 'New menu', highlighted: true, children: [
                  AppDateField(label: 'Effective from *', value: _effectiveFrom, onChanged: (d) => setState(() => _effectiveFrom = d)),
                  Row(children: [
                    Expanded(child: AppTextField(label: 'Food item', hint: 'e.g. Malunggay Soup', icon: Icons.restaurant_outlined, controller: _mealInputController)),
                    const SizedBox(width: 8),
                    IconButton(onPressed: _addItem, icon: const Icon(Icons.add_circle, color: AppColors.primaryGreen, size: 28)),
                  ]),
                  if (_mealItems.isNotEmpty)
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _mealItems.map((item) => Chip(
                            label: Text(item, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.lightGreenBg,
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _mealItems.remove(item)),
                          )).toList(),
                    ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                FormActionButtons(saveLabel: 'Save Meal Plan', onSave: _save, onCancel: () => Navigator.pop(context), isSaving: _isSaving),
                const SizedBox(height: AppSpacing.lg),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _mealInputController.dispose();
    super.dispose();
  }
}