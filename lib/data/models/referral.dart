class Referral {
  final String id;
  final String beneficiaryType; // 'child' or 'mother'
  final String beneficiaryId;
  final String beneficiaryName;
  final String barangay;
  final String reason;
  final String facility;
  final String notes;
  final String status; // 'Pending', 'In Progress', 'Completed', 'Cancelled'
  final DateTime createdAt;

  const Referral({
    required this.id,
    required this.beneficiaryType,
    required this.beneficiaryId,
    required this.beneficiaryName,
    required this.barangay,
    required this.reason,
    required this.facility,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  Referral copyWith({String? status, String? notes}) => Referral(
        id: id,
        beneficiaryType: beneficiaryType,
        beneficiaryId: beneficiaryId,
        beneficiaryName: beneficiaryName,
        barangay: barangay,
        reason: reason,
        facility: facility,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'beneficiaryType': beneficiaryType,
        'beneficiaryId': beneficiaryId,
        'beneficiaryName': beneficiaryName,
        'barangay': barangay,
        'reason': reason,
        'facility': facility,
        'notes': notes,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Referral.fromMap(Map<String, dynamic> map) => Referral(
        id: map['id'] as String,
        beneficiaryType: map['beneficiaryType'] as String,
        beneficiaryId: map['beneficiaryId'] as String,
        beneficiaryName: map['beneficiaryName'] as String,
        barangay: map['barangay'] as String,
        reason: map['reason'] as String,
        facility: map['facility'] as String,
        notes: map['notes'] as String,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}