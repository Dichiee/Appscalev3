import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/local/mother_repository.dart';

class ReferralBeneficiaryResult {
  final String id;
  final String name;
  final String subtitle;
  const ReferralBeneficiaryResult({required this.id, required this.name, required this.subtitle});
}

/// Searchable picker that switches between Child and Mother repositories
/// based on the selected type — the same live-search pattern used
/// throughout the app, generalized to cover both beneficiary kinds.
class ReferralBeneficiaryField extends StatefulWidget {
  final String barangay;
  final String type; // 'child' or 'mother'
  final ValueChanged<String> onTypeChanged;
  final ReferralBeneficiaryResult? selected;
  final ValueChanged<ReferralBeneficiaryResult?> onSelected;

  const ReferralBeneficiaryField({
    super.key,
    required this.barangay,
    required this.type,
    required this.onTypeChanged,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<ReferralBeneficiaryField> createState() => _ReferralBeneficiaryFieldState();
}

class _ReferralBeneficiaryFieldState extends State<ReferralBeneficiaryField> {
  final _searchController = TextEditingController();
  List<ReferralBeneficiaryResult> _results = [];
  bool _isSearching = false;

  void _onQueryChanged(String query) {
    final results = widget.type == 'child'
        ? ChildRepository().search(query, barangay: widget.barangay).map((c) => ReferralBeneficiaryResult(id: c.id, name: c.fullName, subtitle: '${c.ageInMonths} mos · ${c.address}'))
        : MotherRepository().search(query, barangay: widget.barangay).map((m) => ReferralBeneficiaryResult(id: m.id, name: m.fullName, subtitle: m.address));
    setState(() {
      _isSearching = true;
      _results = results.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Beneficiary *', style: AppTextStyles.label),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _typeOption('Child', 'child')),
            const SizedBox(width: 8),
            Expanded(child: _typeOption('Mother', 'mother')),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.selected != null && !_isSearching)
          _selectedCard()
        else ...[
          TextField(
            controller: _searchController,
            onChanged: _onQueryChanged,
            onTap: () => _onQueryChanged(_searchController.text),
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.type == 'child' ? 'Search child by name' : 'Search mother by name',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4)),
            ),
          ),
          if (_isSearching) ...[
            const SizedBox(height: 8),
            if (_results.isEmpty)
              Text('No match found in ${widget.barangay}.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted))
            else
              ..._results.map((r) => InkWell(
                    onTap: () {
                      widget.onSelected(r);
                      setState(() => _isSearching = false);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 15, backgroundColor: AppColors.lightGreenBg, child: Text(r.name[0], style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600, fontSize: 12))),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name, style: AppTextStyles.label.copyWith(fontSize: 13)),
                                Text(r.subtitle, style: AppTextStyles.body.copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ],
      ],
    );
  }

  Widget _typeOption(String label, String value) {
    final selected = widget.type == value;
    return InkWell(
      onTap: () {
        widget.onTypeChanged(value);
        widget.onSelected(null);
        setState(() {
          _isSearching = false;
          _results = [];
          _searchController.clear();
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.border),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _selectedCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryGreen)),
      child: Row(
        children: [
          CircleAvatar(radius: 15, backgroundColor: Colors.white, child: Text(widget.selected!.name[0], style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.selected!.name, style: AppTextStyles.label.copyWith(fontSize: 13)),
                Text(widget.selected!.subtitle, style: AppTextStyles.body.copyWith(fontSize: 11)),
              ],
            ),
          ),
          InkWell(onTap: () => widget.onSelected(null), child: const Icon(Icons.check_circle, color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}