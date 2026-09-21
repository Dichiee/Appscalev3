import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/child_repository.dart';
import '../../data/local/measurement_repository.dart';
import '../../data/local/mother_repository.dart';
import '../../data/local/report_signatory_repository.dart';
import '../../data/local/report_snapshot_repository.dart';
import '../../data/models/report_snapshot.dart';
import '../../shared/utils/app_pickers.dart';
import 'report_types.dart';
import 'services/consolidation_computation_service.dart';
import 'services/excel_table_data.dart';
import 'services/report_excel_service.dart';
import 'services/report_pdf_service.dart';

const _currentBarangay = 'Tiguion'; // TODO: pull from logged-in BNS session

class ReportPreviewScreen extends StatefulWidget {
  final ReportTypeInfo reportType;
  const ReportPreviewScreen({super.key, required this.reportType});

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  DateTime _period = DateTime.now();
  bool _isExporting = false;

  String get _periodLabel => '${_period.year}-${_period.month.toString().padLeft(2, '0')}';

  Future<void> _pickPeriod() async {
    final picked = await showAppDatePicker(context: context, initialDate: _period, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() => _period = DateTime(picked.year, picked.month));
  }

  Future<void> _exportConsolidationPdf() async {
    setState(() => _isExporting = true);
    final counts = ConsolidationComputationService().compute(widget.reportType.id, _currentBarangay);
    final old = ReportSnapshotRepository().getMostRecent(widget.reportType.id, _currentBarangay);
    final signatory = ReportSignatoryRepository().get(_currentBarangay);

    await ReportPdfService().exportAndShare(
      fileTitle: '${widget.reportType.id}_${_periodLabel}_$_currentBarangay',
      title: widget.reportType.title,
      barangay: _currentBarangay,
      period: _periodLabel,
      newCounts: counts,
      oldCounts: old?.counts,
      signatory: signatory,
    );

    await ReportSnapshotRepository().save(ReportSnapshot(
      id: ReportSnapshotRepository.generateId(),
      reportTypeId: widget.reportType.id,
      barangay: _currentBarangay,
      period: _periodLabel,
      counts: counts,
      generatedAt: DateTime.now(),
    ));

    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _exportExcel() async {
    setState(() => _isExporting = true);
    final data = _buildExcelData(widget.reportType.id);
    await ReportExcelService().exportAndShare(
      fileTitle: '${widget.reportType.id}_$_currentBarangay',
      data: data,
      metadataLine: '${widget.reportType.title} · Barangay: $_currentBarangay · Generated: ${DateTime.now().toString().split(' ').first}',
    );
    if (mounted) setState(() => _isExporting = false);
  }

  ExcelTableData _buildExcelData(String reportTypeId) {
    final childRepo = ChildRepository();
    final measurementRepo = MeasurementRepository();

    if (reportTypeId == 'quarterly_weighing') {
      final children = childRepo.getByBarangay(_currentBarangay).where((c) => c.isActive && c.ageInMonths >= 24 && c.ageInMonths < 60).toList();
      final rows = children.map((c) {
        final m = measurementRepo.getForChild(c.id);
        final latest = m.isNotEmpty ? m.first : null;
        return [c.sequenceNo, c.fullName, _fmtDate(c.birthDate), '${c.ageInMonths}', latest?.weightKg.toString() ?? '—', latest?.heightCm.toString() ?? '—', c.nutritionStatus];
      }).toList();
      return ExcelTableData(headers: ['Seq No', 'Name', 'DOB', 'Age (mo)', 'Weight (kg)', 'Height (cm)', 'Status'], rows: rows);
    }

    if (reportTypeId == 'opt_plus') {
      final children = childRepo.getByBarangay(_currentBarangay).where((c) => c.isActive).toList();
      final rows = children.map((c) {
        final m = measurementRepo.getForChild(c.id);
        final latest = m.isNotEmpty ? m.first : null;
        return [
          c.sequenceNo, c.fullName, c.gender, _fmtDate(c.birthDate), '${c.ageInMonths}',
          c.belongsToIpGroup ? 'Yes' : 'No', c.disability,
          latest?.weightKg.toString() ?? '—', latest?.heightCm.toString() ?? '—', latest?.muacCm?.toString() ?? '—',
          (latest?.bilateralPittingEdema ?? false) ? 'Yes' : 'No',
          c.nutritionStatus, c.stuntingStatus, c.wastingStatus,
        ];
      }).toList();
      return ExcelTableData(headers: ['Seq No', 'Name', 'Sex', 'DOB', 'Age (mo)', 'IP Group', 'Disability', 'Weight (kg)', 'Height (cm)', 'MUAC (cm)', 'Edema', 'Weight Status', 'Height Status', 'Wasting Status'], rows: rows);
    }

    if (reportTypeId == 'children_masterlist') {
      final children = childRepo.getByBarangay(_currentBarangay);
      final rows = children.map((c) => [c.sequenceNo, c.fullName, c.gender, _fmtDate(c.birthDate), '${c.ageInMonths}', c.address, c.guardian.fullName, c.guardian.contactNo, c.isActive ? 'Active' : 'Inactive', c.nutritionStatus]).toList();
      return ExcelTableData(headers: ['Seq No', 'Name', 'Gender', 'DOB', 'Age (mo)', 'Address', 'Guardian', 'Guardian Contact', 'Status', 'Nutrition Status'], rows: rows);
    }

    // mothers_masterlist
    final mothers = MotherRepository().getAll().where((m) => m.barangay == _currentBarangay).toList();
    final rows = mothers.map((m) => [m.fullName, '${m.age}', m.address, m.contactNo, m.breastfeedingPractice, m.riskStatus, m.isActive ? 'Active' : 'Inactive']).toList();
    return ExcelTableData(headers: ['Name', 'Age', 'Address', 'Contact', 'Breastfeeding Practice', 'Risk Status', 'Status'], rows: rows);
  }

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isConsolidation = widget.reportType.category == ReportCategory.consolidation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity, color: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Row(children: [
              InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(widget.reportType.title, style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 16))),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (isConsolidation) ...[
                  InkWell(
                    onTap: _pickPeriod,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text('Period: $_periodLabel', style: AppTextStyles.label.copyWith(fontSize: 13)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildConsolidationPreview(),
                  const SizedBox(height: AppSpacing.lg),
                  _exportButton('Export PDF', _exportConsolidationPdf, Icons.picture_as_pdf_outlined),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                    child: Text('Data as of today. Exports as a spreadsheet — no signature block, since this is a data export, not a signed submission.', style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRecordPreview(),
                  const SizedBox(height: AppSpacing.lg),
                  _exportButton('Export Excel', _exportExcel, Icons.grid_on_outlined),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildConsolidationPreview() {
    final counts = ConsolidationComputationService().compute(widget.reportType.id, _currentBarangay);
    final old = ReportSnapshotRepository().getMostRecent(widget.reportType.id, _currentBarangay);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Table(
        border: TableBorder.all(color: AppColors.border, width: 0.5),
        columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
        children: [
          TableRow(decoration: BoxDecoration(color: AppColors.background), children: [
            _cell('', bold: true), _cell('Old', bold: true), _cell('New', bold: true),
          ]),
          ...counts.entries.map((e) => TableRow(children: [
                _cell(e.key), _cell(old?.counts[e.key]?.toString() ?? '—'), _cell(e.value.toString()),
              ])),
        ],
      ),
    );
  }

  Widget _buildRecordPreview() {
    final data = _buildExcelData(widget.reportType.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${data.rows.length} records', style: AppTextStyles.label.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        Text(data.headers.join(' · '), style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
        const Divider(color: AppColors.border),
        ...data.rows.take(5).map((r) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(r.join(' · '), style: AppTextStyles.body.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis))),
        if (data.rows.length > 5) Text('+ ${data.rows.length - 5} more in the exported file', style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _cell(String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      );

  Widget _exportButton(String label, Future<void> Function() onTap, IconData icon) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: FilledButton.icon(
        onPressed: _isExporting ? null : onTap,
        icon: _isExporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(icon, size: 18),
        label: Text(_isExporting ? 'Preparing...' : label),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}