import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/activity_log_repository.dart';
import '../../../data/local/referral_repository.dart';
import '../../../data/models/referral.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_outlined_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class UpdateReferralSheet extends StatefulWidget {
  final Referral referral;
  final VoidCallback? onUpdated;

  const UpdateReferralSheet({
    super.key,
    required this.referral,
    this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Referral referral,
    VoidCallback? onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => UpdateReferralSheet(
        referral: referral,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<UpdateReferralSheet> createState() => _UpdateReferralSheetState();
}

class _UpdateReferralSheetState extends State<UpdateReferralSheet> {
  final _referralRepo = ReferralRepository();
  final _activityRepo = ActivityLogRepository();
  late final TextEditingController _notesController;
  late String _selectedStatus;
  bool _isSaving = false;

  static const _statuses = ['Pending', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.referral.status;
    _notesController = TextEditingController(text: widget.referral.notes);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.statAmber;
      case 'In Progress':
        return AppColors.statBlue;
      case 'Completed':
        return AppColors.primaryGreen;
      case 'Cancelled':
        return AppColors.statRed;
      default:
        return AppColors.textMuted;
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final updated = widget.referral.copyWith(
      status: _selectedStatus,
      notes: _notesController.text.trim(),
    );

    await _referralRepo.update(updated);
    await _activityRepo.logActivity(
      type: 'referral_updated',
      title: 'Updated referral for ${widget.referral.beneficiaryName} to $_selectedStatus',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
    widget.onUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text('Update Referral Status', style: AppTextStyles.h2.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(
            '${widget.referral.beneficiaryName} · ${widget.referral.facility}',
            style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Referral Status', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses.map((s) {
              final isSelected = _selectedStatus == s;
              final color = _statusColor(s);
              return ChoiceChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedStatus = s),
                selectedColor: color.withValues(alpha: 0.16),
                labelStyle: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(color: isSelected ? color : AppColors.border),
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Outcome / Follow-up Notes',
            hint: 'e.g. Treated at RHU, given RUTF, scheduled follow-up visit',
            icon: Icons.notes_outlined,
            controller: _notesController,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Save Status Update',
            onPressed: _handleSave,
            isLoading: _isSaving,
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            label: 'Cancel',
            onPressed: _isSaving ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
