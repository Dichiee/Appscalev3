import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/utils/app_page_route.dart';
import 'report_preview_screen.dart';
import 'report_signatories_screen.dart';
import 'report_types.dart';
import 'sync_status_screen.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  ReportTypeInfo _selected = ReportTypes.consolidation0to23;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(color: AppColors.darkGreen, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Reports & Analytics', style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 20)),
          InkWell(
            onTap: () => Navigator.push(context, appPageRoute(const SyncStatusScreen())),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.sync, color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Report type', style: AppTextStyles.h2.copyWith(fontSize: 15)),
            const SizedBox(height: AppSpacing.sm),
            _section('Consolidation reports', ReportTypes.consolidationTypes),
            const SizedBox(height: AppSpacing.md),
            _section('Individual records', ReportTypes.recordTypes),
            const SizedBox(height: AppSpacing.md),
            _section('Masterlists', ReportTypes.masterlistTypes),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity, height: 52,
              child: FilledButton(
                onPressed: () => Navigator.push(context, appPageRoute(ReportPreviewScreen(reportType: _selected))),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Preview Report', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, appPageRoute(const ReportSignatoriesScreen())),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Edit signatories'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _section(String label, List<ReportTypeInfo> types) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
      ...types.map((t) {
        final selected = _selected.id == t.id;
        return InkWell(
          onTap: () => setState(() => _selected = t),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.lightGreenBg : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.border),
            ),
            child: Row(children: [
              Expanded(child: Text(t.title, style: AppTextStyles.label.copyWith(fontSize: 14, color: selected ? AppColors.darkGreen : AppColors.textPrimary))),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
            ]),
          ),
        );
      }),
    ]);
  }
}