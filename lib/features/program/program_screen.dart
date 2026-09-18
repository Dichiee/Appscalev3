import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/app_data_bus.dart';
import '../../data/local/program_schedule_repository.dart';
import '../../data/models/program_schedule.dart';
import '../../shared/utils/app_page_route.dart';
import '../referrals/referrals_overview_screen.dart';
import 'deworming/deworming_screen.dart';
import 'feeding/feeding_program_screen.dart';
import 'schedule/add_program_schedule_screen.dart';
import 'vitamin_a/vitamin_a_screen.dart';
import 'widgets/program_tile.dart';

class ProgramScreen extends StatefulWidget {
  final String barangay;

  const ProgramScreen({super.key, this.barangay = 'Tiguion'});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  bool _showingPrograms = true;
  String _selectedFilter = 'All';
  final _scheduleRepo = ProgramScheduleRepository();

  @override
  void initState() {
    super.initState();
    _scheduleRepo.seedInitialIfEmpty(widget.barangay);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDataBus.version,
      builder: (context, version, childWidget) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Programs & Schedule',
                    style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _segment('Programs', true)),
                        Expanded(child: _segment('Schedule', false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showingPrograms
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _buildProgramsList(context),
                    )
                  : _buildScheduleView(context),
            ),
          ],
        );
      },
    );
  }

  Widget _segment(String label, bool value) {
    final isSelected = _showingPrograms == value;
    return GestureDetector(
      onTap: () => setState(() => _showingPrograms = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.darkGreen : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProgramsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage and Monitor nutrition programs in your barangay.',
                style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Track participation, schedule activities, and view coverage.',
                style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ProgramTile(
          icon: Icons.soup_kitchen_outlined,
          iconColor: AppColors.primaryGreen,
          title: 'Feeding Program Management',
          subtitle: 'Manage feeding activities and monitor child participation.',
          onTap: () => Navigator.push(context, appPageRoute(const FeedingProgramScreen())),
        ),
        const Divider(color: AppColors.border),
        ProgramTile(
          icon: Icons.local_hospital_outlined,
          iconColor: const Color(0xFFD23369),
          title: 'Referral Monitoring',
          subtitle: 'Monitor referred children and mothers and their follow-up status.',
          onTap: () => Navigator.push(context, appPageRoute(const ReferralsOverviewScreen())),
        ),
        const Divider(color: AppColors.border),
        ProgramTile(
          icon: Icons.medication_outlined,
          iconColor: AppColors.statAmber,
          title: 'Vitamin A Program',
          subtitle: 'Manage Vitamin A supplementation and schedules.',
          onTap: () => Navigator.push(context, appPageRoute(VitaminAScreen(barangay: widget.barangay))),
        ),
        const Divider(color: AppColors.border),
        ProgramTile(
          icon: Icons.healing_outlined,
          iconColor: AppColors.statOrange,
          title: 'Deworming Program',
          subtitle: 'Schedule deworming activities and track coverage.',
          onTap: () => Navigator.push(context, appPageRoute(DewormingScreen(barangay: widget.barangay))),
        ),
      ],
    );
  }

  Widget _buildScheduleView(BuildContext context) {
    final allSchedules = _scheduleRepo.getAllForBarangay(widget.barangay);
    final filtered = _selectedFilter == 'All'
        ? allSchedules
        : allSchedules.where((s) => s.programType == _selectedFilter).toList();

    return Column(
      children: [
        // Action Bar & Filters
        Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          color: AppColors.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Program Schedules', style: AppTextStyles.h2.copyWith(fontSize: 16)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Set Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        appPageRoute(AddProgramScheduleScreen(
                          prefillProgramType: _selectedFilter == 'All' ? 'Feeding' : _selectedFilter,
                        )),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Feeding', 'Vitamin A', 'Deworming', 'OPT Plus'].map((filter) {
                    final isSel = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(filter),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.darkGreen,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSel ? AppColors.darkGreen : AppColors.border),
                        ),
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Schedules List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No scheduled activities found',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Schedule an Activity'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              appPageRoute(const AddProgramScheduleScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    return _buildScheduleCard(s);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(ProgramSchedule s) {
    Color typeColor;
    IconData typeIcon;
    switch (s.programType) {
      case 'Feeding':
        typeColor = AppColors.primaryGreen;
        typeIcon = Icons.soup_kitchen_outlined;
        break;
      case 'Vitamin A':
        typeColor = AppColors.statAmber;
        typeIcon = Icons.medication_outlined;
        break;
      case 'Deworming':
        typeColor = AppColors.statOrange;
        typeIcon = Icons.healing_outlined;
        break;
      default:
        typeColor = Colors.blueAccent;
        typeIcon = Icons.calendar_today_outlined;
    }

    final monthStr = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][s.date.month - 1];

    final isWebAdmin = s.createdBy.contains('Web') || s.createdBy.contains('RHU');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Badge
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  monthStr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                  ),
                ),
                Text(
                  '${s.date.day}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 11, color: typeColor),
                          const SizedBox(width: 3),
                          Text(
                            s.programType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isWebAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RHU Web Admin',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s.title,
                  style: AppTextStyles.h3.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${s.startTime} - ${s.endTime}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        s.location,
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (s.targetGroup.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Target: ${s.targetGroup}',
                    style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.darkGreen, fontWeight: FontWeight.w500),
                  ),
                ],
                if (s.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.notes,
                    style: AppTextStyles.caption.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}