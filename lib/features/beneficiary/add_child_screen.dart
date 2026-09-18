import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/activity_log_repository.dart';
import '../../data/local/beneficiary_link_service.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/models/child.dart';
import '../../data/models/guardian.dart';
import '../../data/models/mother.dart';
import '../../shared/widgets/app_date_field.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_yes_no_toggle.dart';
import '../../shared/widgets/form_action_buttons.dart';
import '../../shared/widgets/form_section_card.dart';
import 'widgets/mother_picker_field.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session
const _currentBarangayCode = 'TIG';

class AddChildScreen extends StatefulWidget {
  /// Pass an existing child to switch this screen into edit mode.
  final Child? existingChild;

  /// Used when this screen is opened as a shortcut from the mother form's
  /// "Register new child" action — pre-fills the guardian section only.
  final String prefillGuardianName;
  final String prefillGuardianContact;
  final String prefillAddress;

  const AddChildScreen({
    super.key,
    this.existingChild,
    this.prefillGuardianName = '',
    this.prefillGuardianContact = '',
    this.prefillAddress = '',
  });

  bool get isEditMode => existingChild != null;

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _childRepo = ChildRepository();
  final _motherRepo = MotherRepository();
  final _activityRepo = ActivityLogRepository();
  final _linkService = BeneficiaryLinkService();

  late final _fullNameController = TextEditingController(text: widget.existingChild?.fullName ?? '');
  late final _addressController = TextEditingController(text: widget.existingChild?.address ?? widget.prefillAddress);
  late final _guardianNameController = TextEditingController(text: widget.existingChild?.guardian.fullName ?? widget.prefillGuardianName);
  late final _guardianContactController = TextEditingController(text: widget.existingChild?.guardian.contactNo ?? widget.prefillGuardianContact);
  late final _disabilityController = TextEditingController(text: widget.existingChild?.disability == 'None specified' ? '' : widget.existingChild?.disability ?? '');

  DateTime? _birthDate;
  String _gender = 'Female';
  bool _belongsToIpGroup = false;
  String _relationship = 'Mother';
  bool _guardianIsMonitoredMother = false;
  Mother? _linkedMother;
  bool _isSaving = false;

  late final String _sequenceNo = widget.existingChild?.sequenceNo ?? _childRepo.generateSequenceNo(barangayCode: _currentBarangayCode);

  @override
  void initState() {
    super.initState();
    final existing = widget.existingChild;
    if (existing != null) {
      _birthDate = existing.birthDate;
      _gender = existing.gender;
      _belongsToIpGroup = existing.belongsToIpGroup;
      _relationship = existing.guardian.relationship;
      if (existing.guardian.linkedMotherId != null) {
        _linkedMother = _motherRepo.getById(existing.guardian.linkedMotherId!);
        _guardianIsMonitoredMother = _linkedMother != null;
      }
    }
  }

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _addressController.text.trim().isNotEmpty &&
      _guardianNameController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final child = Child(
      id: widget.existingChild?.id ?? ChildRepository.generateId(),
      sequenceNo: _sequenceNo,
      fullName: _fullNameController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender,
      address: _addressController.text.trim(),
      barangay: _currentBarangay,
      belongsToIpGroup: _belongsToIpGroup,
      disability: _disabilityController.text.trim().isEmpty ? 'None specified' : _disabilityController.text.trim(),
      guardian: Guardian(
        fullName: _guardianNameController.text.trim(),
        relationship: _relationship,
        contactNo: _guardianContactController.text.trim(),
        linkedMotherId: _guardianIsMonitoredMother ? _linkedMother?.id : null,
      ),
      createdAt: widget.existingChild?.createdAt ?? DateTime.now(),
      nutritionStatus: widget.existingChild?.nutritionStatus ?? 'Not weighed',
      lastWeighedAt: widget.existingChild?.lastWeighedAt,
      isActive: widget.existingChild?.isActive ?? true,
      inactiveReason: widget.existingChild?.inactiveReason,
      stuntingStatus: widget.existingChild?.stuntingStatus ?? 'Not weighed',
      wastingStatus: widget.existingChild?.wastingStatus ?? 'Not weighed',
    );

    if (widget.isEditMode) {
      await _childRepo.update(child);
    } else {
      await _childRepo.add(child);
    }

    final oldMotherId = widget.existingChild?.guardian.linkedMotherId;
    if (_guardianIsMonitoredMother && _linkedMother != null) {
      if (oldMotherId != null && oldMotherId != _linkedMother!.id) {
        final oldMother = _motherRepo.getById(oldMotherId);
        if (oldMother != null) {
          await _linkService.unlinkChildFromMother(child: child, mother: oldMother);
        }
      }
      await _linkService.linkChildToMother(child: child, mother: _linkedMother!);
    } else if (oldMotherId != null) {
      final oldMother = _motherRepo.getById(oldMotherId);
      if (oldMother != null) {
        await _linkService.unlinkChildFromMother(child: child, mother: oldMother);
      }
    }

    await _activityRepo.logActivity(
      type: 'child_added',
      title: widget.isEditMode ? 'Updated ${child.fullName}\'s profile' : 'Registered ${child.fullName}',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ScreenHeader(title: widget.isEditMode ? 'Edit Child Profile' : 'Add Child Profile'),
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
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.body.copyWith(fontSize: 12),
                              children: [
                                const TextSpan(text: 'Sequence no. '),
                                TextSpan(text: _sequenceNo, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                TextSpan(text: widget.isEditMode ? '' : ' · auto-assigned'),
                              ],
                            ),
                          ),
                        ),
                        AppTextField(label: 'Full Name *', hint: "Enter child's full name", icon: Icons.badge_outlined, controller: _fullNameController),
                        Row(
                          children: [
                            Expanded(child: AppDateField(label: 'Birth date *', value: _birthDate, onChanged: (d) => setState(() => _birthDate = d))),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: AppDropdownField(label: 'Gender *', value: _gender, options: const ['Female', 'Male'], onChanged: (v) => setState(() => _gender = v!))),
                          ],
                        ),
                        AppTextField(label: 'Address *', hint: 'Purok, Tiguion', icon: Icons.location_on_outlined, controller: _addressController),
                        AppYesNoToggle(label: 'Belongs to IP group', value: _belongsToIpGroup, onChanged: (v) => setState(() => _belongsToIpGroup = v)),
                        AppTextField(label: 'Disability, if any', hint: 'None specified', icon: Icons.accessibility_new_outlined, controller: _disabilityController),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FormSectionCard(
                      title: 'Guardian',
                      subtitle: 'Required for every child, even if not a monitored mother',
                      children: [
                        AppTextField(label: 'Full Name *', hint: "Enter guardian's name", icon: Icons.person_outline, controller: _guardianNameController),
                        Row(
                          children: [
                            Expanded(child: AppDropdownField(label: 'Relationship', value: _relationship, options: const ['Mother', 'Father', 'Grandparent', 'Other'], onChanged: (v) => setState(() => _relationship = v!))),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: AppTextField(label: 'Contact no.', hint: '09XXXXXXXXX', icon: Icons.call_outlined, controller: _guardianContactController)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryGreen)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('Guardian is also a monitored mother?', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.darkGreen))),
                              Switch(
                                value: _guardianIsMonitoredMother,
                                activeThumbColor: AppColors.primaryGreen,
                                onChanged: (v) => setState(() {
                                  _guardianIsMonitoredMother = v;
                                  if (!v) _linkedMother = null;
                                }),
                              ),
                            ],
                          ),
                        ),
                        if (_guardianIsMonitoredMother)
                          MotherPickerField(
                            barangay: _currentBarangay,
                            selected: _linkedMother,
                            prefillFullName: _guardianNameController.text,
                            prefillContact: _guardianContactController.text,
                            prefillAddress: _addressController.text,
                            onSelected: (mother) => setState(() {
                              _linkedMother = mother;
                              if (mother != null) {
                                _guardianNameController.text = mother.fullName;
                                _guardianContactController.text = mother.contactNo;
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FormActionButtons(
                      saveLabel: widget.isEditMode ? 'Save Changes' : 'Save Child Profile',
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
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _disabilityController.dispose();
    super.dispose();
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  const _ScreenHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: AppTextStyles.h2.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}