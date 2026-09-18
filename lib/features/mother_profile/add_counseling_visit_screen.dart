import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/activity_log_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/local/mother_risk_service.dart';
import '../../data/local/mother_visit_repository.dart';
import '../../data/models/mother.dart';
import '../../data/models/mother_visit.dart';
import '../../shared/utils/app_pickers.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/widgets/app_outlined_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/form_section_card.dart';
import '../referrals/create_referral_screen.dart';
import '../../shared/utils/app_page_route.dart';
import '../../shared/widgets/urgent_referral_dialog.dart';

const _kAccent = Color(0xFF9A2D5E);
const _kTopics = ['Proper latching', 'Maternal nutrition', 'Hygiene', 'Complementary feeding'];

class AddCounselingVisitScreen extends StatefulWidget {
  final Mother mother;
  const AddCounselingVisitScreen({super.key, required this.mother});

  @override
  State<AddCounselingVisitScreen> createState() => _AddCounselingVisitScreenState();
}

class _AddCounselingVisitScreenState extends State<AddCounselingVisitScreen> {
  final _visitRepo = MotherVisitRepository();
  final _motherRepo = MotherRepository();
  final _riskService = MotherRiskService();
  final _activityRepo = ActivityLogRepository();
  final _concernNoteController = TextEditingController();
  final _observationNoteController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _present = true;
  String _breastfeedingPractice = 'Exclusive breastfeeding';
  final Set<String> _topics = {};
  bool _hasConcern = false;
  String _observation = 'Appears well';
  bool _isSaving = false;

  bool get _isFormValid => !_present || _observation != 'Signs of concern' || _observationNoteController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe what was observed')));
      return;
    }

    setState(() => _isSaving = true);

    final visit = MotherVisit(
      date: _date,
      present: _present,
      breastfeedingPractice: _present ? _breastfeedingPractice : null,
      topicsCounseled: _present ? _topics.toList() : [],
      hasMedicalConcern: _present && _hasConcern,
      concernNote: _present && _hasConcern ? _concernNoteController.text.trim() : null,
      observation: _present ? _observation : null,
      observationNote: _present && _observation == 'Signs of concern' ? _observationNoteController.text.trim() : null,
    );

    await _visitRepo.addVisit(widget.mother.id, visit);
    await _riskService.recomputeAndSave(widget.mother.id);
    await _activityRepo.logActivity(type: 'mother_visit_logged', title: 'Logged a visit for ${widget.mother.fullName}');

    if (!mounted) return;

    // Fires on either signal: an explicit medical concern, or the
    // observation itself crossing into "Signs of concern" — same
    // trigger logic as the child side, just sourced from a visit
    // instead of a measurement.
    final needsReferralPrompt = _present && (_observation == 'Signs of concern' || _hasConcern);
    if (needsReferralPrompt && mounted) {
      final reason = _buildMotherReferralReason();
      await UrgentReferralDialog.show(
        context,
        beneficiaryName: widget.mother.fullName,
        reason: reason,
        onCreateReferral: () async {
          await Navigator.push(context, appPageRoute(CreateReferralScreen(
            prefillBeneficiaryType: 'mother',
            prefillBeneficiaryId: widget.mother.id,
            prefillBeneficiaryName: widget.mother.fullName,
            prefillReason: reason,
          )));
        },
        onLater: () {},
      );
    }

    if (visit.stoppedBreastfeeding && mounted) {
      await _promptInactive();
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  String _buildMotherReferralReason() {
    final parts = <String>[];
    if (_observation == 'Signs of concern' && _observationNoteController.text.trim().isNotEmpty) parts.add(_observationNoteController.text.trim());
    if (_hasConcern && _concernNoteController.text.trim().isNotEmpty) parts.add(_concernNoteController.text.trim());
    return parts.isEmpty ? 'Signs of concern observed' : parts.join(' · ');
  }


  Future<void> _promptInactive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Breastfeeding has stopped'),
        content: Text('Move ${widget.mother.fullName} to Inactive? Her record and visit history stay saved and searchable.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not yet')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move to Inactive')),
        ],
      ),
    );
    if (confirmed == true) {
      final mother = _motherRepo.getById(widget.mother.id);
      if (mother != null) {
        await _motherRepo.update(mother.copyWith(isActive: false, inactiveReason: 'Stopped breastfeeding'));
      }
    }
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
              color: _kAccent,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Add counseling visit', style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 17)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mother.fullName, style: AppTextStyles.label.copyWith(fontSize: 15)),
                    const SizedBox(height: AppSpacing.lg),
                    _DateField(value: _date, onChanged: (d) => setState(() => _date = d)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Did the mother show up?', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _toggle('Present', _present, () => setState(() => _present = true))),
                        const SizedBox(width: 8),
                        Expanded(child: _toggle('Missed', !_present, () => setState(() => _present = false))),
                      ],
                    ),
                    if (_present) ...[
                      const SizedBox(height: AppSpacing.lg),
                      FormSectionCard(
                        title: 'Visit details',
                        highlighted: true,
                        children: [
                          AppDropdownField(
                            label: 'Current breastfeeding practice',
                            value: _breastfeedingPractice,
                            options: const ['Exclusive breastfeeding', 'Mixed feeding', 'Complementary feeding', 'Bottle feeding', 'Stopped breastfeeding'],
                            onChanged: (v) => setState(() => _breastfeedingPractice = v!),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Topics counseled', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _kTopics.map((t) {
                                  final selected = _topics.contains(t);
                                  return FilterChip(
                                    label: Text(t),
                                    selected: selected,
                                    onSelected: (_) => setState(() => selected ? _topics.remove(t) : _topics.add(t)),
                                    selectedColor: _kAccent.withValues(alpha: 0.14),
                                    labelStyle: TextStyle(color: selected ? _kAccent : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                    side: BorderSide(color: selected ? _kAccent : AppColors.border),
                                    backgroundColor: AppColors.surface,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Any medical concern raised?', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: _toggle('No', !_hasConcern, () => setState(() => _hasConcern = false))),
                                  const SizedBox(width: 8),
                                  Expanded(child: _toggle('Yes', _hasConcern, () => setState(() => _hasConcern = true))),
                                ],
                              ),
                              if (_hasConcern) ...[
                                const SizedBox(height: 10),
                                AppTextField(label: 'Describe the concern', hint: 'e.g. mastitis, low milk supply', icon: Icons.medical_information_outlined, controller: _concernNoteController),
                              ],
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your observation of her condition', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: _toggle('Appears well', _observation == 'Appears well', () => setState(() => _observation = 'Appears well'))),
                                  const SizedBox(width: 8),
                                  Expanded(child: _toggle('Signs of concern', _observation == 'Signs of concern', () => setState(() => _observation = 'Signs of concern'), danger: true)),
                                ],
                              ),
                              if (_observation == 'Signs of concern') ...[
                                const SizedBox(height: 10),
                                AppTextField(label: 'Note, required', hint: 'e.g. looks thin, pale, fatigued', icon: Icons.notes_outlined, controller: _observationNoteController),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(label: 'Save visit', onPressed: _handleSave, isLoading: _isSaving),
                    const SizedBox(height: 10),
                    AppOutlinedButton(label: 'Cancel', onPressed: _isSaving ? null : () => Navigator.pop(context)),
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

  Widget _toggle(String label, bool selected, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? AppColors.statRed : _kAccent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  void dispose() {
    _concernNoteController.dispose();
    _observationNoteController.dispose();
    super.dispose();
  }
}

class _DateField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const _DateField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visit date', style: AppTextStyles.label),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showAppDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}