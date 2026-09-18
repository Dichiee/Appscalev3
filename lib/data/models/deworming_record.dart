class DewormingRecord {
  final String id;
  final String childId;
  final String childName;
  final String barangay;
  final int ageInMonths;
  final DateTime dateGiven;
  final String drugName; // 'Albendazole 400mg' or 'Mebendazole 500mg'
  final String round; // '1st Round (Jan - Jun)', '2nd Round (Jul - Dec)', 'Catch-up'
  final String adverseEvents; // 'None', 'Mild Nausea', 'Abdominal Discomfort', etc.
  final String administeredBy;
  final String remarks;
  final DateTime? nextDueDate;
  final DateTime createdAt;

  const DewormingRecord({
    required this.id,
    required this.childId,
    required this.childName,
    required this.barangay,
    required this.ageInMonths,
    required this.dateGiven,
    required this.drugName,
    required this.round,
    this.adverseEvents = 'None',
    required this.administeredBy,
    this.remarks = '',
    this.nextDueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'childId': childId,
        'childName': childName,
        'barangay': barangay,
        'ageInMonths': ageInMonths,
        'dateGiven': dateGiven.toIso8601String(),
        'drugName': drugName,
        'round': round,
        'adverseEvents': adverseEvents,
        'administeredBy': administeredBy,
        'remarks': remarks,
        'nextDueDate': nextDueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory DewormingRecord.fromMap(Map<dynamic, dynamic> map) => DewormingRecord(
        id: map['id'] as String,
        childId: map['childId'] as String,
        childName: map['childName'] as String,
        barangay: map['barangay'] as String,
        ageInMonths: (map['ageInMonths'] as num?)?.toInt() ?? 0,
        dateGiven: DateTime.parse(map['dateGiven'] as String),
        drugName: map['drugName'] as String,
        round: map['round'] as String? ?? '1st Round (Jan - Jun)',
        adverseEvents: map['adverseEvents'] as String? ?? 'None',
        administeredBy: map['administeredBy'] as String? ?? 'BNS',
        remarks: map['remarks'] as String? ?? '',
        nextDueDate: map['nextDueDate'] != null
            ? DateTime.parse(map['nextDueDate'] as String)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
