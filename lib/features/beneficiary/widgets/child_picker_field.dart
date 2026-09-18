import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/models/child.dart';
import '../add_child_screen.dart';

class ChildPickerField extends StatefulWidget {
  final String barangay;
  final List<Child> selected;
  final ValueChanged<List<Child>> onChanged;
  final String prefillGuardianName;
  final String prefillGuardianContact;
  final String prefillAddress;

  const ChildPickerField({
    super.key,
    required this.barangay,
    required this.selected,
    required this.onChanged,
    this.prefillGuardianName = '',
    this.prefillGuardianContact = '',
    this.prefillAddress = '',
  });

  @override
  State<ChildPickerField> createState() => _ChildPickerFieldState();
}

class _ChildPickerFieldState extends State<ChildPickerField> {
  final _repo = ChildRepository();
  final _searchController = TextEditingController();
  String _query = '';

  void _toggle(Child child) {
    final isSelected = widget.selected.any((c) => c.id == child.id);
    final updated = isSelected
        ? widget.selected.where((c) => c.id != child.id).toList()
        : [...widget.selected, child];
    widget.onChanged(updated);
  }

  Future<void> _registerNewChild() async {
    final created = await Navigator.push<Child>(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildScreen(
          prefillGuardianName: widget.prefillGuardianName,
          prefillGuardianContact: widget.prefillGuardianContact,
          prefillAddress: widget.prefillAddress,
        ),
      ),
    );
    if (created != null) {
      widget.onChanged([...widget.selected, created]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChildren = _repo.getByBarangay(widget.barangay).where((c) => c.isActive).toList();
    final matches = _query.isEmpty
        ? allChildren
        : allChildren.where((c) => c.fullName.toLowerCase().contains(_query.toLowerCase())).toList();
    final selectedIds = widget.selected.map((c) => c.id).toSet();
    final filtered = [
      ...matches.where((c) => selectedIds.contains(c.id)),
      ...matches.where((c) => !selectedIds.contains(c.id)).take(10),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Linked Child', style: AppTextStyles.label),
            InkWell(
              onTap: _registerNewChild,
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text('Register new child', style: AppTextStyles.body.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search children by name',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4)),
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          Text('No children found in ${widget.barangay}.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted))
        else
          ...filtered.map((child) {
            final isSelected = widget.selected.any((c) => c.id == child.id);
            return InkWell(
              onTap: () => _toggle(child),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightGreenBg : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: AppColors.lightGreenBg, child: Text(child.initials, style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.fullName, style: AppTextStyles.label),
                          Text('${child.ageInMonths} mos · ${child.address}', style: AppTextStyles.body.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}