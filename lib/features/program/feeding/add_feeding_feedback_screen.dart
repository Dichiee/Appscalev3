import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/feeding_feedback_repository.dart';
import '../../../data/models/feeding_feedback.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/form_action_buttons.dart';
import '../../../shared/widgets/form_section_card.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class AddFeedingFeedbackScreen extends StatefulWidget {
  const AddFeedingFeedbackScreen({super.key});

  @override
  State<AddFeedingFeedbackScreen> createState() => _AddFeedingFeedbackScreenState();
}

class _AddFeedingFeedbackScreenState extends State<AddFeedingFeedbackScreen> {
  final _noteController = TextEditingController();
  DateTime? _date = DateTime.now();
  String? _tag = 'Went well';
  bool _isSaving = false;

  Future<void> _save() async {
    if (_noteController.text.trim().isEmpty || _date == null) return;
    setState(() => _isSaving = true);
    await FeedingFeedbackRepository().add(FeedingFeedback(
      id: FeedingFeedbackRepository.generateId(),
      date: _date!,
      note: _noteController.text.trim(),
      tag: _tag,
      barangay: _currentBarangay,
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
              Text('Session Feedback', style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FormSectionCard(title: 'How did it go?', highlighted: true, children: [
                  AppDateField(label: 'Date', value: _date, onChanged: (d) => setState(() => _date = d)),
                  Row(children: [
                    Expanded(child: _tagOption('Went well', AppColors.primaryGreen)),
                    const SizedBox(width: 8),
                    Expanded(child: _tagOption('Needs improvement', AppColors.statOrange)),
                  ]),
                  AppTextField(label: 'Notes', hint: 'What did you observe?', icon: Icons.notes_outlined, controller: _noteController, maxLines: 4),
                ]),
                const SizedBox(height: AppSpacing.xl),
                FormActionButtons(saveLabel: 'Save Feedback', onSave: _save, onCancel: () => Navigator.pop(context), isSaving: _isSaving),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tagOption(String label, Color color) {
    final selected = _tag == label;
    return InkWell(
      onTap: () => setState(() => _tag = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? color : AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? color : AppColors.border)),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}