import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/activity_log_repository.dart';
import '../../data/local/beneficiary_link_service.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/models/child.dart';
import '../../data/models/mother.dart';
import '../../shared/widgets/app_date_field.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_yes_no_toggle.dart';
import '../../shared/widgets/form_action_buttons.dart';
import '../../shared/widgets/form_section_card.dart';
import 'widgets/child_picker_field.dart';
import '../../data/local/mother_visit_repository.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class AddMotherScreen extends StatefulWidget {
  final Mother? existingMother;

  /// Used when opened as a shortcut from the child form's
  /// "Create mother profile" action — pre-fills Personal Information only.
  final String prefillFullName;
  final String prefillContact;
  final String prefillAddress;

  const AddMotherScreen({
    super.key,
    this.existingMother,
    this.prefillFullName = '',
    this.prefillContact = '',
    this.prefillAddress = '',
  });

  bool get isEditMode => existingMother != null;

  @override
  State<AddMotherScreen> createState() => _AddMotherScreenState();
}

class _AddMotherScreenState extends State<AddMotherScreen> {
  final _motherRepo = MotherRepository();
  final _childRepo = ChildRepository();
  final _activityRepo = ActivityLogRepository();
  final _linkService = BeneficiaryLinkService();

  late final _fullNameController = TextEditingController(text: widget.existingMother?.fullName ?? widget.prefillFullName);
  late final _contactController = TextEditingController(text: widget.existingMother?.contactNo ?? widget.prefillContact);
  late final _addressController = TextEditingController(text: widget.existingMother?.address ?? widget.prefillAddress);
  late final _disabilityController = TextEditingController(text: widget.existingMother?.disability == 'None specified' ? '' : widget.existingMother?.disability ?? '');

  DateTime? _birthDate;
  String _breastfeedingPractice = 'Exclusive breastfeeding';
  bool _belongsToIpGroup = false;
  List<Child> _linkedChildren = [];
  bool _isSaving = false;
  bool get _hasLoggedVisits => widget.isEditMode && MotherVisitRepository().getForMother(widget.existingMother!.id).isNotEmpty;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMother;
    if (existing != null) {
      _birthDate = existing.birthDate;
      _breastfeedingPractice = existing.breastfeedingPractice;
      _belongsToIpGroup = existing.belongsToIpGroup;
      _linkedChildren = _childRepo.getByIds(existing.linkedChildIds);
    }
  }

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _addressController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final mother = Mother(
      id: widget.existingMother?.id ?? MotherRepository.generateId(),
      fullName: _fullNameController.text.trim(),
      birthDate: _birthDate!,
      contactNo: _contactController.text.trim(),
      address: _addressController.text.trim(),
      barangay: _currentBarangay,
      breastfeedingPractice: _breastfeedingPractice,
      belongsToIpGroup: _belongsToIpGroup,
      disability: _disabilityController.text.trim().isEmpty ? 'None specified' : _disabilityController.text.trim(),
      createdAt: widget.existingMother?.createdAt ?? DateTime.now(),
      riskStatus: widget.existingMother?.riskStatus ?? 'Normal',
      isActive: widget.existingMother?.isActive ?? true,
      inactiveReason: widget.existingMother?.inactiveReason,
      linkedChildIds: _linkedChildren.map((c) => c.id).toList(),
    );

    if (widget.isEditMode) {
      await _motherRepo.update(mother);
    } else {
      await _motherRepo.add(mother);
    }

    // Reciprocal write-back: every linked child (whether pre-existing or
    // newly registered through the shortcut) gets its guardian.linkedMotherId
    // set to this mother, so the link is provably true from both sides.
    if (widget.isEditMode) {
      final currentLinkedIds = _linkedChildren.map((c) => c.id).toSet();
      for (final oldChildId in widget.existingMother!.linkedChildIds) {
        if (!currentLinkedIds.contains(oldChildId)) {
          final oldChildren = _childRepo.getByIds([oldChildId]);
          if (oldChildren.isNotEmpty) {
            await _linkService.unlinkChildFromMother(child: oldChildren.first, mother: mother);
          }
        }
      }
    }

    for (final child in _linkedChildren) {
      await _linkService.linkChildToMother(child: child, mother: mother);
    }

    await _activityRepo.logActivity(
      type: 'mother_added',
      title: widget.isEditMode ? 'Updated ${mother.fullName}\'s profile' : 'Registered ${mother.fullName}',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, mother);
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
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.arrow_back, color: Colors.white)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(widget.isEditMode ? 'Edit Mother Profile' : 'Add Mother Profile', style: AppTextStyles.h2.copyWith(color: Colors.white)),
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
                      title: 'Personal Information',
                      highlighted: true,
                      children: [
                        AppTextField(label: 'Full Name *', hint: "Enter mother's full name", icon: Icons.badge_outlined, controller: _fullNameController),
                        Row(
                          children: [
                            Expanded(child: AppDateField(label: 'Birth Date *', value: _birthDate, onChanged: (d) => setState(() => _birthDate = d))),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: AppTextField(label: 'Contact no.', hint: '09XXXXXXXXX', icon: Icons.call_outlined, controller: _contactController)),
                          ],
                        ),
                        AppTextField(label: 'Address *', hint: 'Purok, Tiguion', icon: Icons.location_on_outlined, controller: _addressController),
                        if (_hasLoggedVisits)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Expanded(child: Text('Breastfeeding practice: $_breastfeedingPractice', style: AppTextStyles.body.copyWith(fontSize: 12))),
                                const Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                              ],
                            ),
                          )
                        else
                          AppDropdownField(
                            label: 'Current breastfeeding practice',
                            value: _breastfeedingPractice,
                            options: const ['Exclusive breastfeeding', 'Mixed feeding', 'Complementary feeding', 'Bottle feeding'],
                            onChanged: (v) => setState(() => _breastfeedingPractice = v!),
                          ),
                        AppYesNoToggle(label: 'Belongs to IP group', value: _belongsToIpGroup, onChanged: (v) => setState(() => _belongsToIpGroup = v)),
                        AppTextField(label: 'Disability, if any', hint: 'None specified', icon: Icons.accessibility_new_outlined, controller: _disabilityController),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FormSectionCard(
                      title: 'Linked Children',
                      subtitle: 'Children this mother is a guardian or caregiver for',
                      children: [
                        ChildPickerField(
                          barangay: _currentBarangay,
                          selected: _linkedChildren,
                          prefillGuardianName: _fullNameController.text,
                          prefillGuardianContact: _contactController.text,
                          prefillAddress: _addressController.text,
                          onChanged: (children) => setState(() => _linkedChildren = children),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FormActionButtons(
                      saveLabel: widget.isEditMode ? 'Save Changes' : 'Save Mother Profile',
                      onSave: _handleSave,
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
    _fullNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _disabilityController.dispose();
    super.dispose();
  }
}