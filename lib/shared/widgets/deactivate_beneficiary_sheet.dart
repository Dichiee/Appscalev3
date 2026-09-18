import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Generic reason-required deactivation sheet, reused by both Child and
/// Mother profiles. Returns the chosen reason string, or null if cancelled —
/// the calling screen is responsible for actually writing it to the record,
/// since Child and Mother repositories are different types.
class DeactivateBeneficiarySheet extends StatefulWidget {
  final String beneficiaryName;
  final List<String> reasons;
  final Color accentColor;

  const DeactivateBeneficiarySheet({
    super.key,
    required this.beneficiaryName,
    required this.reasons,
    required this.accentColor,
  });

  static Future<String?> show(
    BuildContext context, {
    required String beneficiaryName,
    required List<String> reasons,
    Color accentColor = AppColors.primaryGreen,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DeactivateBeneficiarySheet(beneficiaryName: beneficiaryName, reasons: reasons, accentColor: accentColor),
    );
  }

  @override
  State<DeactivateBeneficiarySheet> createState() => _DeactivateBeneficiarySheetState();
}

class _DeactivateBeneficiarySheetState extends State<DeactivateBeneficiarySheet> {
  final _otherController = TextEditingController();
  late String _reason = widget.reasons.first;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.sm, bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppSpacing.lg), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
          Text('Move ${widget.beneficiaryName} to Inactive', style: AppTextStyles.h2.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('This requires a reason so the record stays traceable.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: (v) {
              if (v != null) setState(() => _reason = v);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.reasons.map((r) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: r,
                    title: Text(r, style: AppTextStyles.body.copyWith(fontSize: 13)),
                    activeColor: widget.accentColor,
                  )).toList(),
            ),
          ),
          if (_reason == 'Other') ...[
            const SizedBox(height: 6),
            AppTextField(label: 'Please specify', hint: 'Reason', icon: Icons.edit_note_outlined, controller: _otherController),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Confirm',
            onPressed: () => Navigator.pop(context, _reason == 'Other' ? (_otherController.text.trim().isEmpty ? 'Other' : _otherController.text.trim()) : _reason),
          ),
        ],
      ),
    );
  }
}