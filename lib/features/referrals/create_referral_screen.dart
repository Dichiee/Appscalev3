import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/activity_log_repository.dart';
import '../../data/local/referral_repository.dart';
import '../../data/models/referral.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/form_action_buttons.dart';
import '../../shared/widgets/form_section_card.dart';
import 'referral_constants.dart';
import 'widgets/referral_beneficiary_field.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class CreateReferralScreen extends StatefulWidget {
  final String? prefillBeneficiaryType;
  final String? prefillBeneficiaryId;
  final String? prefillBeneficiaryName;
  final String? prefillBeneficiarySubtitle;
  final String? prefillReason;

  const CreateReferralScreen({
    super.key,
    this.prefillBeneficiaryType,
    this.prefillBeneficiaryId,
    this.prefillBeneficiaryName,
    this.prefillBeneficiarySubtitle,
    this.prefillReason,
  });

  bool get isPrefilled => prefillBeneficiaryId != null;

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _referralRepo = ReferralRepository();
  final _activityRepo = ActivityLogRepository();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  late String _type = widget.prefillBeneficiaryType ?? 'child';
  late ReferralBeneficiaryResult? _selected = widget.isPrefilled
      ? ReferralBeneficiaryResult(id: widget.prefillBeneficiaryId!, name: widget.prefillBeneficiaryName!, subtitle: widget.prefillBeneficiarySubtitle ?? '')
      : null;
  String _facility = ReferralConstants.facilities.first;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillReason != null) _reasonController.text = widget.prefillReason!;
  }

  bool get _isFormValid => _selected != null && _reasonController.text.trim().isNotEmpty;

  Future<void> _handleSubmit() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a beneficiary and describe the reason')));
      return;
    }

    setState(() => _isSaving = true);

    final referral = Referral(
      id: ReferralRepository.generateId(),
      beneficiaryType: _type,
      beneficiaryId: _selected!.id,
      beneficiaryName: _selected!.name,
      barangay: _currentBarangay,
      reason: _reasonController.text.trim(),
      facility: _facility,
      notes: _notesController.text.trim(),
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    await _referralRepo.add(referral);
    await _activityRepo.logActivity(type: 'referral_created', title: 'Referral created for ${referral.beneficiaryName}');

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, referral);
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Referrals', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSectionCard(
                      title: 'Create Referral',
                      highlighted: true,
                      children: [
                        if (widget.isPrefilled)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Referral for ${_selected!.name}, based on their recent record.', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted))),
                              ],
                            ),
                          )
                        else
                          ReferralBeneficiaryField(
                            barangay: _currentBarangay,
                            type: _type,
                            onTypeChanged: (t) => setState(() => _type = t),
                            selected: _selected,
                            onSelected: (r) => setState(() => _selected = r),
                          ),
                        AppTextField(label: 'Referral Reason *', hint: 'Describe the reason for referral...', icon: Icons.notes_outlined, controller: _reasonController, maxLines: 3),
                        AppDropdownField(label: 'Assigned Facility *', value: _facility, options: ReferralConstants.facilities, onChanged: (v) => setState(() => _facility = v!)),
                        AppTextField(label: 'Notes (Optional)', hint: 'Additional notes...', icon: Icons.edit_note_outlined, controller: _notesController, maxLines: 2),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FormActionButtons(
                      saveLabel: 'Submit Referral',
                      onSave: _handleSubmit,
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
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}