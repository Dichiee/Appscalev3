import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/mother_repository.dart';
import '../../../data/models/mother.dart';
import '../add_mother_screen.dart';


/// Single-select searchable field for linking a guardian to an existing
/// monitored mother record — or creating one on the spot if she isn't
/// registered yet, pre-filled with what's already typed into the form.
class MotherPickerField extends StatefulWidget {
  final String barangay;
  final Mother? selected;
  final ValueChanged<Mother?> onSelected;
  final String prefillFullName;
  final String prefillContact;
  final String prefillAddress;

  const MotherPickerField({
    super.key,
    required this.barangay,
    required this.selected,
    required this.onSelected,
    this.prefillFullName = '',
    this.prefillContact = '',
    this.prefillAddress = '',
  });

  @override
  State<MotherPickerField> createState() => _MotherPickerFieldState();
}

class _MotherPickerFieldState extends State<MotherPickerField> {
  final _repo = MotherRepository();
  final _searchController = TextEditingController();
  List<Mother> _results = [];
  bool _isSearching = false;

  void _onQueryChanged(String query) {
    setState(() {
      _isSearching = true;
      _results = _repo.search(query, barangay: widget.barangay);
    });
  }

  Future<void> _createMotherProfile() async {
    final created = await Navigator.push<Mother>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMotherScreen(
          prefillFullName: _searchController.text.isNotEmpty ? _searchController.text : widget.prefillFullName,
          prefillContact: widget.prefillContact,
          prefillAddress: widget.prefillAddress,
        ),
      ),
    );
    if (created != null) {
      widget.onSelected(created);
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected != null && !_isSearching) {
      return _SelectedMotherCard(
        mother: widget.selected!,
        onChange: () => setState(() => _isSearching = true),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Link to mother record', style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: _searchController,
          onChanged: _onQueryChanged,
          onTap: () => _onQueryChanged(_searchController.text),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search mother by name',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No mother found in ${widget.barangay}.',
                    style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _createMotherProfile,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 16, color: AppColors.darkGreen),
                          const SizedBox(width: 6),
                          Text('Create mother profile', style: TextStyle(color: AppColors.darkGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._results.map((m) => _ResultTile(
                  mother: m,
                  onTap: () {
                    widget.onSelected(m);
                    setState(() => _isSearching = false);
                  },
                )),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ResultTile extends StatelessWidget {
  final Mother mother;
  final VoidCallback onTap;
  const _ResultTile({required this.mother, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.lightGreenBg, child: Text(mother.fullName[0], style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mother.fullName, style: AppTextStyles.label),
                  Text(mother.address, style: AppTextStyles.body.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMotherCard extends StatelessWidget {
  final Mother mother;
  final VoidCallback onChange;
  const _SelectedMotherCard({required this.mother, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Linked Mother record', style: AppTextStyles.label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryGreen)),
          child: Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Text(mother.fullName[0], style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mother.fullName, style: AppTextStyles.label),
                    Text(mother.address, style: AppTextStyles.body.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              InkWell(onTap: onChange, child: const Icon(Icons.check_circle, color: AppColors.primaryGreen)),
            ],
          ),
        ),
      ],
    );
  }
}