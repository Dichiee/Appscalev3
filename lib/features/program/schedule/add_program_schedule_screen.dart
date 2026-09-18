import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/program_schedule_repository.dart';
import '../../../data/models/program_schedule.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/form_action_buttons.dart';
import '../../../shared/widgets/form_section_card.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class AddProgramScheduleScreen extends StatefulWidget {
  final String? prefillProgramType;
  final String? initialTitle;

  const AddProgramScheduleScreen({
    super.key,
    this.prefillProgramType,
    this.initialTitle,
  });

  @override
  State<AddProgramScheduleScreen> createState() => _AddProgramScheduleScreenState();
}

class _AddProgramScheduleScreenState extends State<AddProgramScheduleScreen> {
  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController(text: '08:30 AM');
  final _endTimeController = TextEditingController(text: '11:30 AM');
  final _locationController = TextEditingController();
  final _targetGroupController = TextEditingController();
  final _notesController = TextEditingController();

  late String _programType = widget.prefillProgramType ?? 'Feeding';
  DateTime? _date = DateTime.now().add(const Duration(days: 1));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      _titleController.text = widget.initialTitle!;
    }
    _applyDefaultsForType(_programType);
  }

  void _applyDefaultsForType(String type) {
    if (_titleController.text.isEmpty || _isDefaultTitle(_titleController.text)) {
      switch (type) {
        case 'Feeding':
          _titleController.text = 'Supplementary Feeding Session';
          _targetGroupController.text = 'Enrolled SAM and MAM children';
          _locationController.text = 'Barangay Covered Court';
          break;
        case 'Vitamin A':
          _titleController.text = 'Vitamin A Supplementation Distribution';
          _targetGroupController.text = 'Children 6–59 months';
          _locationController.text = 'Barangay Health Center';
          break;
        case 'Deworming':
          _titleController.text = 'National Deworming Round';
          _targetGroupController.text = 'Children 1–4 years (12–59 mos)';
          _locationController.text = 'Barangay Day Care Center';
          break;
        case 'OPT Plus':
          _titleController.text = 'Operation Timbang Plus Weighing';
          _targetGroupController.text = 'All 0–59 months in Barangay';
          _locationController.text = 'Purok Health Post';
          break;
      }
    }
  }

  bool _isDefaultTitle(String t) {
    return t == 'Supplementary Feeding Session' ||
        t == 'Vitamin A Supplementation Distribution' ||
        t == 'National Deworming Round' ||
        t == 'Operation Timbang Plus Weighing';
  }

  bool get _isFormValid =>
      _titleController.text.trim().isNotEmpty &&
      _date != null &&
      _locationController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title, date, and venue')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final schedule = ProgramSchedule(
      id: ProgramScheduleRepository.generateId(),
      title: _titleController.text.trim(),
      programType: _programType,
      date: _date!,
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      location: _locationController.text.trim(),
      targetGroup: _targetGroupController.text.trim().isEmpty
          ? 'Community beneficiaries'
          : _targetGroupController.text.trim(),
      notes: _notesController.text.trim(),
      barangay: _currentBarangay,
      createdBy: 'BNS Mobile',
      createdAt: DateTime.now(),
    );

    await ProgramScheduleRepository().save(schedule);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Set Program Schedule',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedules set here are linked to the program timeline and displayed directly on the Dashboard.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FormSectionCard(
                      title: 'Program Details',
                      highlighted: true,
                      children: [
                        AppDropdownField(
                          label: 'Program *',
                          value: _programType,
                          options: const ['Feeding', 'Vitamin A', 'Deworming', 'OPT Plus'],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _programType = v;
                                _applyDefaultsForType(v);
                              });
                            }
                          },
                        ),
                        AppTextField(
                          label: 'Activity Title *',
                          hint: 'e.g. Supplementary Feeding Session',
                          icon: Icons.event_note_outlined,
                          controller: _titleController,
                        ),
                        AppDateField(
                          label: 'Scheduled Date *',
                          value: _date,
                          onChanged: (d) => setState(() => _date = d),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Start Time',
                                hint: '08:30 AM',
                                icon: Icons.access_time,
                                controller: _startTimeController,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppTextField(
                                label: 'End Time',
                                hint: '11:30 AM',
                                icon: Icons.access_time_filled,
                                controller: _endTimeController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FormSectionCard(
                      title: 'Location & Target Group',
                      children: [
                        AppTextField(
                          label: 'Location / Venue *',
                          hint: 'e.g. Barangay Health Center, Covered Court',
                          icon: Icons.location_on_outlined,
                          controller: _locationController,
                        ),
                        AppTextField(
                          label: 'Target Group',
                          hint: 'e.g. Children 6–59 months',
                          icon: Icons.groups_outlined,
                          controller: _targetGroupController,
                        ),
                        AppTextField(
                          label: 'Notes / Reminders',
                          hint: 'e.g. Remind parents to bring immunization cards',
                          icon: Icons.notes_outlined,
                          controller: _notesController,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FormActionButtons(
                      saveLabel: 'Save Schedule',
                      onSave: _save,
                      onCancel: () => Navigator.pop(context),
                      isSaving: _isSaving,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _targetGroupController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
