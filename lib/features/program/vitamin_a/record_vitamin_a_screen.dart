import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/local/vitamin_a_repository.dart';
import '../../../data/models/child.dart';
import '../../../data/models/vitamin_a_record.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_date_field.dart';

class RecordVitaminAScreen extends StatefulWidget {
  final Child? initialChild;

  const RecordVitaminAScreen({super.key, this.initialChild});

  @override
  State<RecordVitaminAScreen> createState() => _RecordVitaminAScreenState();
}

class _RecordVitaminAScreenState extends State<RecordVitaminAScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childRepo = ChildRepository();
  final _vitARepo = VitaminARepository();

  List<Child> _allChildren = [];
  Child? _selectedChild;
  DateTime _dateGiven = DateTime.now();
  String _dosage = '100,000 IU (Blue)';
  String _doseType = 'Routine (6-11 mos)';
  final _adminByCtrl = TextEditingController(text: 'BNS Maria');
  final _remarksCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _allChildren = _childRepo.getByBarangay('Tiguion');
    if (widget.initialChild != null) {
      _selectedChild = widget.initialChild;
    } else if (_allChildren.isNotEmpty) {
      _selectedChild = _allChildren.first;
    }
    _applyDohRulesForChild(_selectedChild);
  }

  @override
  void dispose() {
    _adminByCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _applyDohRulesForChild(Child? child) {
    if (child == null) return;
    final age = child.ageInMonths;
    setState(() {
      if (age < 6) {
        _dosage = 'Not Recommended (<6 mos)';
        _doseType = 'High Risk / Sick Child';
      } else if (age <= 11) {
        _dosage = '100,000 IU (Blue)';
        _doseType = 'Routine (6-11 mos)';
      } else {
        _dosage = '200,000 IU (Red)';
        _doseType = 'Routine (12-59 mos)';
      }
    });
  }

  Future<void> _save() async {
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final record = VitaminARecord(
        id: const Uuid().v4(),
        childId: _selectedChild!.id,
        childName: _selectedChild!.fullName,
        barangay: _selectedChild!.barangay,
        ageInMonths: _selectedChild!.ageInMonths,
        dateGiven: _dateGiven,
        dosage: _dosage,
        doseType: _doseType,
        administeredBy: _adminByCtrl.text.trim().isEmpty ? 'BNS Maria' : _adminByCtrl.text.trim(),
        remarks: _remarksCtrl.text.trim(),
        nextDueDate: _dateGiven.add(const Duration(days: 180)),
        createdAt: DateTime.now(),
      );

      await _vitARepo.save(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vitamin A recorded for ${_selectedChild!.fullName}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _selectedChild?.ageInMonths ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Vitamin A'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Beneficiary Details', style: AppTextStyles.h2.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),

              // Child selector
              if (widget.initialChild != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.initialChild!.fullName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${widget.initialChild!.ageLabel} (${widget.initialChild!.ageInMonths} months) • ${widget.initialChild!.gender}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<Child>(
                  initialValue: _selectedChild,
                  decoration: InputDecoration(
                    labelText: 'Select Child',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _allChildren.map((child) {
                    return DropdownMenuItem(
                      value: child,
                      child: Text(
                        '${child.fullName} (${child.ageLabel})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedChild = val;
                      _applyDohRulesForChild(val);
                    });
                  },
                ),

              const SizedBox(height: AppSpacing.md),

              // DOH Guidance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: age < 6
                      ? AppColors.statRed.withValues(alpha: 0.1)
                      : (age <= 11 ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: age < 6
                        ? AppColors.statRed
                        : (age <= 11 ? Colors.blue : Colors.orange),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      age < 6 ? Icons.warning_amber_rounded : Icons.info_outline,
                      color: age < 6
                          ? AppColors.statRed
                          : (age <= 11 ? Colors.blue : Colors.orange),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            age < 6
                                ? 'Under Age Warning'
                                : (age <= 11
                                    ? 'DOH Standard: 6–11 Months'
                                    : 'DOH Standard: 12–59 Months'),
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 13,
                              color: age < 6
                                  ? AppColors.statRed
                                  : (age <= 11 ? Colors.blue[800] : Colors.orange[900]),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            age < 6
                                ? 'Routine Vitamin A capsule is contraindicated for infants under 6 months. Exclusive breastfeeding provides sufficient Vitamin A.'
                                : (age <= 11
                                    ? 'Recommended dosage: 100,000 IU (Blue Capsule) given once.'
                                    : 'Recommended dosage: 200,000 IU (Red Capsule) given every 6 months.'),
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Text('Administration Details', style: AppTextStyles.h2.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),

              AppDateField(
                label: 'Date Given',
                value: _dateGiven,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onChanged: (d) => setState(() => _dateGiven = d),
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<String>(
                value: _dosage,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '100,000 IU (Blue)',
                    child: Text('100,000 IU (Blue Capsule) - 6-11 mos'),
                  ),
                  DropdownMenuItem(
                    value: '200,000 IU (Red)',
                    child: Text('200,000 IU (Red Capsule) - 12-59 mos'),
                  ),
                  DropdownMenuItem(
                    value: 'Not Recommended (<6 mos)',
                    child: Text('Not Recommended (< 6 mos)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _dosage = val);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<String>(
                value: _doseType,
                decoration: InputDecoration(
                  labelText: 'Dose Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Routine (6-11 mos)',
                    child: Text('Routine (6-11 mos)'),
                  ),
                  DropdownMenuItem(
                    value: 'Routine (12-59 mos)',
                    child: Text('Routine (12-59 mos)'),
                  ),
                  DropdownMenuItem(
                    value: 'High Risk / Sick Child',
                    child: Text('High Risk / Sick Child (Measles/Diarrhea)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _doseType = val);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _adminByCtrl,
                decoration: InputDecoration(
                  labelText: 'Administered By',
                  hintText: 'e.g. BNS Maria',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _remarksCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Remarks / Observations (Optional)',
                  hintText: 'e.g. Well-tolerated, no vomiting',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Save Vitamin A Record',
                onPressed: _save,
                isLoading: _saving,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
