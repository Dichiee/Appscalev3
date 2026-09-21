class ReportSnapshot {
  final String id;
  final String reportTypeId;
  final String barangay;
  final String period; // e.g. '2026-09'
  final Map<String, int> counts;
  final DateTime generatedAt;

  const ReportSnapshot({
    required this.id,
    required this.reportTypeId,
    required this.barangay,
    required this.period,
    required this.counts,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'reportTypeId': reportTypeId,
        'barangay': barangay,
        'period': period,
        'counts': counts,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory ReportSnapshot.fromMap(Map<String, dynamic> map) => ReportSnapshot(
        id: map['id'] as String,
        reportTypeId: map['reportTypeId'] as String,
        barangay: map['barangay'] as String,
        period: map['period'] as String,
        counts: Map<String, int>.from(map['counts'] as Map),
        generatedAt: DateTime.parse(map['generatedAt'] as String),
      );
}