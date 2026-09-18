class VitaminARecord {
  final String id;
  final String childId;
  final String childName;
  final String barangay;
  final int ageInMonths;
  final DateTime dateGiven;
  final String dosage; // '100,000 IU (Blue)' or '200,000 IU (Red)'
  final String doseType; // 'Routine (6-11 mos)', 'Routine (12-59 mos)', 'High Risk / Sick Child'
  final String administeredBy;
  final String remarks;
  final DateTime? nextDueDate;
  final DateTime createdAt;

  const VitaminARecord({
    required this.id,
    required this.childId,
    required this.childName,
    required this.barangay,
    required this.ageInMonths,
    required this.dateGiven,
    required this.dosage,
    required this.doseType,
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
        'dosage': dosage,
        'doseType': doseType,
        'administeredBy': administeredBy,
        'remarks': remarks,
        'nextDueDate': nextDueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory VitaminARecord.fromMap(Map<dynamic, dynamic> map) => VitaminARecord(
        id: map['id'] as String,
        childId: map['childId'] as String,
        childName: map['childName'] as String,
        barangay: map['barangay'] as String,
        ageInMonths: (map['ageInMonths'] as num?)?.toInt() ?? 0,
        dateGiven: DateTime.parse(map['dateGiven'] as String),
        dosage: map['dosage'] as String,
        doseType: map['doseType'] as String? ?? 'Routine',
        administeredBy: map['administeredBy'] as String? ?? 'BNS',
        remarks: map['remarks'] as String? ?? '',
        nextDueDate: map['nextDueDate'] != null
            ? DateTime.parse(map['nextDueDate'] as String)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
