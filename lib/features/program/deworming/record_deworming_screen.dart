import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/local/deworming_repository.dart';
import '../../../data/models/child.dart';
import '../../../data/models/deworming_record.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_date_field.dart';

class RecordDewormingScreen extends StatefulWidget {
  final Child? initialChild;

  const RecordDewormingScreen({super.key, this.initialChild});

  @override
  State<RecordDewormingScreen> createState() => _RecordDewormingScreenState();
}

class _RecordDewormingScreenState extends State<RecordDewormingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childRepo = ChildRepository();
  final _dewormingRepo = DewormingRepository();

  List<Child> _allChildren = [];
  Child? _selectedChild;
  DateTime _dateGiven = DateTime.now();
  String _drugName = 'Albendazole 400mg';
  late String _round;
  String _adverseEvents = 'None';
  final _adminByCtrl = TextEditingController(text: 'BNS Maria');
  final _remarksCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _round = DewormingRepository.currentNationalRound();
    _allChildren = _childRepo.getByBarangay('Tiguion');
    if (widget.initialChild != null) {
      _selectedChild = widget.initialChild;
    } else {
      // Prefer children >= 12 months
      final eligible = _allChildren.where((c) => c.ageInMonths >= 12).toList();
      _selectedChild = eligible.isNotEmpty ? eligible.first : (_allChildren.isNotEmpty ? _allChildren.first : null);
    }
  }

  @override
  void dispose() {
    _adminByCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child')),
      );
      return;
    }
    if (_selectedChild!.ageInMonths < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot administer deworming: Child is under 12 months old'),
          backgroundColor: AppColors.statRed,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final record = DewormingRecord(
        id: const Uuid().v4(),
        childId: _selectedChild!.id,
        childName: _selectedChild!.fullName,
        barangay: _selectedChild!.barangay,
        ageInMonths: _selectedChild!.ageInMonths,
        dateGiven: _dateGiven,
        drugName: _drugName,
        round: _round,
        adverseEvents: _adverseEvents,
        administeredBy: _adminByCtrl.text.trim().isEmpty ? 'BNS Maria' : _adminByCtrl.text.trim(),
        remarks: _remarksCtrl.text.trim(),
        nextDueDate: _dateGiven.add(const Duration(days: 180)),
        createdAt: DateTime.now(),
      );

      await _dewormingRepo.save(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deworming recorded for ${_selectedChild!.fullName}'),
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
    final isUnder12Mos = age < 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Deworming'),
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
                    final eligible = child.ageInMonths >= 12;
                    return DropdownMenuItem(
                      value: child,
                      child: Text(
                        '${child.fullName} (${child.ageLabel})${eligible ? '' : ' - UNDER 12 MOS'}',
                        style: TextStyle(
                          color: eligible ? Colors.black87 : AppColors.statRed,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedChild = val);
                  },
                ),

              const SizedBox(height: AppSpacing.md),

              // DOH Deworming Age Guidance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isUnder12Mos
                      ? AppColors.statRed.withValues(alpha: 0.1)
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnder12Mos ? AppColors.statRed : AppColors.primaryGreen,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isUnder12Mos ? Icons.block : Icons.check_circle_outline,
                      color: isUnder12Mos ? AppColors.statRed : AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUnder12Mos
                                ? 'Contraindication: Under 12 Months'
                                : 'DOH Target Age: 12–59 Months (1–4 yrs)',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 13,
                              color: isUnder12Mos ? AppColors.statRed : AppColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUnder12Mos
                                ? 'Deworming medications (Albendazole/Mebendazole) are NOT recommended for children under 1 year of age per DOH guidelines.'
                                : 'Preschool-age children receive mass deworming twice a year (every 6 months) under the National Deworming Program.',
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
                initialValue: _drugName,
                decoration: InputDecoration(
                  labelText: 'Deworming Drug & Dosage',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Albendazole 400mg',
                    child: Text('Albendazole 400mg (Single Chewable Tablet)'),
                  ),
                  DropdownMenuItem(
                    value: 'Mebendazole 500mg',
                    child: Text('Mebendazole 500mg (Single Tablet)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _drugName = val);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<String>(
                initialValue: _round,
                decoration: InputDecoration(
                  labelText: 'Campaign Round',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1st Round (Jan - Jun)',
                    child: Text('1st Round (Jan - Jun)'),
                  ),
                  DropdownMenuItem(
                    value: '2nd Round (Jul - Dec)',
                    child: Text('2nd Round (Jul - Dec)'),
                  ),
                  DropdownMenuItem(
                    value: 'Catch-up',
                    child: Text('Catch-up Administration'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _round = val);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<String>(
                initialValue: _adverseEvents,
                decoration: InputDecoration(
                  labelText: 'Adverse Reactions Observed',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'None',
                    child: Text('None (Well Tolerated)'),
                  ),
                  DropdownMenuItem(
                    value: 'Mild Nausea',
                    child: Text('Mild Nausea'),
                  ),
                  DropdownMenuItem(
                    value: 'Abdominal Discomfort',
                    child: Text('Abdominal Discomfort / Cramps'),
                  ),
                  DropdownMenuItem(
                    value: 'Vomiting',
                    child: Text('Vomiting'),
                  ),
                  DropdownMenuItem(
                    value: 'Headache',
                    child: Text('Headache'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other Reaction'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _adverseEvents = val);
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
                  hintText: 'e.g. Ingested under direct observation',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Save Deworming Record',
                onPressed: isUnder12Mos ? null : _save,
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
