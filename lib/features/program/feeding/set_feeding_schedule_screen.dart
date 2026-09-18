import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/feeding_schedule_repository.dart';
import '../../../data/models/feeding_schedule.dart';
import '../../../shared/widgets/app_date_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_yes_no_toggle.dart';
import '../../../shared/widgets/form_action_buttons.dart';
import '../../../shared/widgets/form_section_card.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session
const _dayOrder = [1, 2, 3, 4, 5, 6, 7];
const _dayLabels = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};

class SetFeedingScheduleScreen extends StatefulWidget {
  const SetFeedingScheduleScreen({super.key});

  @override
  State<SetFeedingScheduleScreen> createState() => _SetFeedingScheduleScreenState();
}

class _SetFeedingScheduleScreenState extends State<SetFeedingScheduleScreen> {
  final _locationController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final Set<int> _selectedDays = {};
  DateTime? _startDate;
  bool _ongoing = true;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = FeedingScheduleRepository().get(_currentBarangay);
    if (existing != null) {
      _selectedDays.addAll(existing.daysOfWeek);
      _startTimeController.text = existing.startTime;
      _endTimeController.text = existing.endTime;
      _locationController.text = existing.location;
      _startDate = existing.startDate;
      _ongoing = existing.endDate == null;
      _endDate = existing.endDate;
    }
  }

  bool get _isFormValid => _selectedDays.isNotEmpty && _startDate != null && _locationController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one day, a start date, and a location')));
      return;
    }
    setState(() => _isSaving = true);
    await FeedingScheduleRepository().save(FeedingSchedule(
      daysOfWeek: _selectedDays.toList(),
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      location: _locationController.text.trim(),
      startDate: _startDate!,
      endDate: _ongoing ? null : _endDate,
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
              Text('Feeding Schedule', style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Set once — this defines the recurring pattern so attendance days never need to be re-entered.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.md),
                FormSectionCard(title: 'Recurrence', highlighted: true, children: [
                  Text('Days *', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _dayOrder.map((d) {
                      final selected = _selectedDays.contains(d);
                      return ChoiceChip(
                        label: Text(_dayLabels[d]!),
                        selected: selected,
                        onSelected: (_) => setState(() => selected ? _selectedDays.remove(d) : _selectedDays.add(d)),
                        selectedColor: AppColors.primaryGreen.withOpacity(0.16),
                        labelStyle: TextStyle(color: selected ? AppColors.primaryGreen : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                        side: BorderSide(color: selected ? AppColors.primaryGreen : AppColors.border),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
                  ),
                  Row(children: [
                    Expanded(child: AppTextField(label: 'Start time', hint: '8:00 AM', icon: Icons.schedule_outlined, controller: _startTimeController)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: AppTextField(label: 'End time', hint: '10:00 AM', icon: Icons.schedule_outlined, controller: _endTimeController)),
                  ]),
                  AppTextField(label: 'Location *', hint: 'e.g. Brgy. Hall', icon: Icons.location_on_outlined, controller: _locationController),
                  AppDateField(label: 'Start date *', value: _startDate, onChanged: (d) => setState(() => _startDate = d)),
                  AppYesNoToggle(label: 'Ongoing (no end date)', value: _ongoing, onChanged: (v) => setState(() => _ongoing = v)),
                  if (!_ongoing) AppDateField(label: 'End date', value: _endDate, onChanged: (d) => setState(() => _endDate = d)),
                ]),
                const SizedBox(height: AppSpacing.xl),
                FormActionButtons(saveLabel: 'Save Schedule', onSave: _save, onCancel: () => Navigator.pop(context), isSaving: _isSaving),
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
    _locationController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}