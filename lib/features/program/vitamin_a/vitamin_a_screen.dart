import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/app_data_bus.dart';
import '../../../data/local/child_repository.dart';
import '../../../data/local/vitamin_a_repository.dart';
import '../../../data/models/child.dart';
import '../../../data/models/vitamin_a_record.dart';
import '../../../shared/utils/app_page_route.dart';
import '../schedule/add_program_schedule_screen.dart';
import 'record_vitamin_a_screen.dart';

class VitaminAScreen extends StatefulWidget {
  final String barangay;

  const VitaminAScreen({super.key, this.barangay = 'Tiguion'});

  @override
  State<VitaminAScreen> createState() => _VitaminAScreenState();
}

class _VitaminAScreenState extends State<VitaminAScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _vitARepo = VitaminARepository();
  final _childRepo = ChildRepository();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vitARepo.seedInitialIfEmpty(widget.barangay);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, version, childWidget) {
        final records = _vitARepo.getAllForBarangay(widget.barangay);
        final allChildren = _childRepo.getByBarangay(widget.barangay).where((c) => c.isActive).toList();
        final eligibleChildren = allChildren.where((c) => c.ageInMonths >= 6 && c.ageInMonths <= 59).toList();

        // Children who received Vit A in last 6 months
        final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
        final recentRecipients = records
            .where((r) => r.dateGiven.isAfter(sixMonthsAgo))
            .map((r) => r.childId)
            .toSet();

        final coveragePct = eligibleChildren.isEmpty
            ? 0
            : ((recentRecipients.length / eligibleChildren.length) * 100).round();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vitamin A Program'),
            backgroundColor: AppColors.darkGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: 'Schedule Vitamin A Activity',
                onPressed: () {
                  Navigator.push(
                    context,
                    appPageRoute(AddProgramScheduleScreen(
                      prefillProgramType: 'Vitamin A',
                      initialTitle: 'Barangay Vitamin A Supplementation',
                    )),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Records (${records.length})'),
                Tab(text: 'Eligible Children (${eligibleChildren.length})'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Summary Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Target Eligible',
                        '${eligibleChildren.length}',
                        '6-59 mos',
                        Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        'Given (6 mos)',
                        '${recentRecipients.length}',
                        'Children',
                        AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        'Coverage',
                        '$coveragePct%',
                        coveragePct >= 90 ? 'Optimal' : 'Needs Follow-up',
                        coveragePct >= 90 ? AppColors.primaryGreen : AppColors.statOrange,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search child name...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecordsList(records),
                    _buildEligibleList(eligibleChildren, recentRecipients),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.darkGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Record Vit A'),
            onPressed: () {
              Navigator.push(
                context,
                appPageRoute(const RecordVitaminAScreen()),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(String title, String val, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(val, style: AppTextStyles.h2.copyWith(fontSize: 18, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<VitaminARecord> records) {
    final filtered = _searchQuery.isEmpty
        ? records
        : records.where((r) => r.childName.toLowerCase().contains(_searchQuery)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.medication_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('No Vitamin A records found', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 80),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = filtered[i];
        final isBlue = r.dosage.contains('Blue') || r.dosage.contains('100,000');
        final dateStr = '${r.dateGiven.month}/${r.dateGiven.day}/${r.dateGiven.year}';
        final nextDueStr = r.nextDueDate != null
            ? '${r.nextDueDate!.month}/${r.nextDueDate!.day}/${r.nextDueDate!.year}'
            : '—';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isBlue ? Colors.blue[100] : Colors.red[100],
                    child: Icon(
                      Icons.medication,
                      size: 18,
                      color: isBlue ? Colors.blue[800] : Colors.red[800],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.childName, style: AppTextStyles.h3.copyWith(fontSize: 14)),
                        Text('${r.doseType} • Age: ${r.ageInMonths} mos', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBlue ? Colors.blue[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isBlue ? Colors.blue : Colors.red),
                    ),
                    child: Text(
                      r.dosage,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isBlue ? Colors.blue[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Given: $dateStr by ${r.administeredBy}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  Text('Next Due: $nextDueStr', style: AppTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkGreen)),
                ],
              ),
              if (r.remarks.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Note: ${r.remarks}', style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic, color: AppColors.textMuted)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEligibleList(List<Child> eligible, Set<String> recentRecipients) {
    final filtered = _searchQuery.isEmpty
        ? eligible
        : eligible.where((c) => c.fullName.toLowerCase().contains(_searchQuery)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('No eligible children found', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 80),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final child = filtered[i];
        final hasReceived = recentRecipients.contains(child.id);
        final isBlue = child.ageInMonths <= 11;
        final recommendedDose = isBlue ? '100,000 IU (Blue)' : '200,000 IU (Red)';

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.darkGreen.withValues(alpha: 0.1),
                child: Text(
                  child.initials,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkGreen, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.fullName, style: AppTextStyles.h3.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${child.ageLabel} (${child.ageInMonths} mos) • Rec: $recommendedDose', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasReceived)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.primaryGreen),
                      SizedBox(width: 4),
                      Text('Done', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 11)),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      appPageRoute(RecordVitaminAScreen(initialChild: child)),
                    );
                  },
                  child: const Text('Give Dose'),
                ),
            ],
          ),
        );
      },
    );
  }
}
