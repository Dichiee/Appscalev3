import 'package:flutter/material.dart';
import 'app_button.dart';
import 'app_outlined_button.dart';

/// Save + Cancel pair, reused by every add/edit form. Keeps button order,
/// spacing, and behavior identical across the whole app.
class FormActionButtons extends StatelessWidget {
  final String saveLabel;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  const FormActionButtons({
    super.key,
    required this.saveLabel,
    required this.onSave,
    required this.onCancel,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(label: saveLabel, onPressed: onSave, isLoading: isSaving),
        const SizedBox(height: 10),
        AppOutlinedButton(label: 'Cancel', onPressed: isSaving ? null : onCancel),
      ],
    );
  }
}