import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/utils/app_page_route.dart';
import '../referrals/referrals_overview_screen.dart';
import 'widgets/program_tile.dart';
import 'feeding/feeding_program_screen.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  bool _showingPrograms = true;

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — coming next')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Programs & Schedule', style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 20)),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _showingPrograms ? _buildProgramsList(context) : _buildScheduleEmpty(),
          ),
        ),
      ],
    );
  }

  Widget _segment(String label, bool value) {
    final isSelected = _showingPrograms == value;
    return GestureDetector(
      onTap: () => setState(() => _showingPrograms = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.darkGreen : Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
          decoration: BoxDecoration(color: AppColors.darkGreen, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage and Monitor nutrition programs in your barangay.', style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Track participation, schedule activities, and view coverage.', style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12)),
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
          onTap: () => _comingSoon(context, 'Vitamin A Program'),
        ),
        const Divider(color: AppColors.border),
        ProgramTile(
          icon: Icons.healing_outlined,
          iconColor: AppColors.statOrange,
          title: 'Deworming Program',
          subtitle: 'Schedule deworming activities and track coverage.',
          onTap: () => _comingSoon(context, 'Deworming Program'),
        ),
      ],
    );
  }

  Widget _buildScheduleEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.event_available_outlined, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text('Schedule — coming next', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}