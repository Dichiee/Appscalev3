import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/report_signatory_repository.dart';
import '../../data/models/report_signatory.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/form_action_buttons.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session
const _currentBnsName = 'Maria D. Santos'; // TODO: pull from logged-in BNS session

class ReportSignatoriesScreen extends StatefulWidget {
  const ReportSignatoriesScreen({super.key});

  @override
  State<ReportSignatoriesScreen> createState() => _ReportSignatoriesScreenState();
}

class _ReportSignatoriesScreenState extends State<ReportSignatoriesScreen> {
  final _punongBarangayController = TextEditingController();
  final _mnaoController = TextEditingController();
  final _dnpcController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = ReportSignatoryRepository().get(_currentBarangay);
    if (existing != null) {
      _punongBarangayController.text = existing.punongBarangayName;
      _mnaoController.text = existing.mnaoAdminAideName;
      _dnpcController.text = existing.dnpcName;
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await ReportSignatoryRepository().save(ReportSignatory(
      barangay: _currentBarangay,
      bnsName: _currentBnsName,
      punongBarangayName: _punongBarangayController.text.trim(),
      mnaoAdminAideName: _mnaoController.text.trim(),
      dnpcName: _dnpcController.text.trim(),
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
              Text('Report Signatories', style: AppTextStyles.h2.copyWith(color: Colors.white)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('These names print automatically on every report. Update only when an official changes.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.lg),
                Text('Submitted by (BNS)', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                  child: Text('$_currentBnsName · auto-filled from account', style: AppTextStyles.body.copyWith(fontSize: 13)),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Noted by · Punong Barangay', hint: 'Full name', icon: Icons.person_outline, controller: _punongBarangayController),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Approved by · Admin Aide, MNAO', hint: 'Full name', icon: Icons.person_outline, controller: _mnaoController),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Approved by · DNPC', hint: 'Full name', icon: Icons.person_outline, controller: _dnpcController),
                const SizedBox(height: AppSpacing.xl),
                FormActionButtons(saveLabel: 'Save Signatories', onSave: _save, onCancel: () => Navigator.pop(context), isSaving: _isSaving),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _punongBarangayController.dispose();
    _mnaoController.dispose();
    _dnpcController.dispose();
    super.dispose();
  }
}