enum ReportCategory { consolidation, individualRecord, masterlist }

enum ExportFormat { pdf, excel }

class ReportTypeInfo {
  final String id;
  final String title;
  final ReportCategory category;
  final List<ExportFormat> formats;

  const ReportTypeInfo({required this.id, required this.title, required this.category, required this.formats});
}

/// The registry of every report the app can generate. Adding a new
/// report type means adding one entry here — the hub screen, preview
/// screen, and export buttons all read from this list, not a hardcoded UI.
class ReportTypes {
  ReportTypes._();

  static const consolidation0to23 = ReportTypeInfo(id: 'consolidation_0_23', title: 'Consolidation, 0–23 months', category: ReportCategory.consolidation, formats: [ExportFormat.pdf]);
  static const consolidation24to59 = ReportTypeInfo(id: 'consolidation_24_59', title: 'Consolidation, 24–59 months', category: ReportCategory.consolidation, formats: [ExportFormat.pdf]);
  static const underweightSuw = ReportTypeInfo(id: 'uw_suw', title: 'Underweight / severely underweight', category: ReportCategory.consolidation, formats: [ExportFormat.pdf]);
  static const stuntedSst = ReportTypeInfo(id: 'stunted_sst', title: 'Stunted / severely stunted', category: ReportCategory.consolidation, formats: [ExportFormat.pdf]);
  static const quarterlyWeighing = ReportTypeInfo(id: 'quarterly_weighing', title: 'Quarterly full weighing record', category: ReportCategory.individualRecord, formats: [ExportFormat.excel]);
  static const optPlus = ReportTypeInfo(id: 'opt_plus', title: 'OPT Plus report', category: ReportCategory.individualRecord, formats: [ExportFormat.excel]);
  static const childrenMasterlist = ReportTypeInfo(id: 'children_masterlist', title: 'Children masterlist', category: ReportCategory.masterlist, formats: [ExportFormat.excel]);
  static const mothersMasterlist = ReportTypeInfo(id: 'mothers_masterlist', title: 'Mothers masterlist', category: ReportCategory.masterlist, formats: [ExportFormat.excel]);

  static const consolidationTypes = [consolidation0to23, consolidation24to59, underweightSuw, stuntedSst];
  static const recordTypes = [quarterlyWeighing, optPlus];
  static const masterlistTypes = [childrenMasterlist, mothersMasterlist];
  static const all = [...consolidationTypes, ...recordTypes, ...masterlistTypes];
}