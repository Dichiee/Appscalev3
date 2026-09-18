class Mother {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String contactNo;
  final String address;
  final String barangay;
  final String breastfeedingPractice;
  final bool belongsToIpGroup;
  final String disability;
  final DateTime createdAt;
  final String riskStatus; // 'Normal' or 'At-risk'
  final bool isActive;
  final String? inactiveReason; // 'Stopped breastfeeding', 'Transferred', 'Deceased'
  final List<String> linkedChildIds;

  const Mother({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.contactNo,
    required this.address,
    required this.barangay,
    required this.breastfeedingPractice,
    required this.belongsToIpGroup,
    required this.disability,
    required this.createdAt,
    this.riskStatus = 'Normal',
    this.isActive = true,
    this.inactiveReason,
    this.linkedChildIds = const [],
  });

  int get age => (DateTime.now().difference(birthDate).inDays / 365).floor();

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'contactNo': contactNo,
        'address': address,
        'barangay': barangay,
        'breastfeedingPractice': breastfeedingPractice,
        'belongsToIpGroup': belongsToIpGroup,
        'disability': disability,
        'createdAt': createdAt.toIso8601String(),
        'riskStatus': riskStatus,
        'isActive': isActive,
        'inactiveReason': inactiveReason,
        'linkedChildIds': linkedChildIds,
      };

  factory Mother.fromMap(Map map) => Mother(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        contactNo: map['contactNo'] as String,
        address: map['address'] as String,
        barangay: map['barangay'] as String,
        breastfeedingPractice: map['breastfeedingPractice'] as String,
        belongsToIpGroup: map['belongsToIpGroup'] as bool,
        disability: map['disability'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        riskStatus: map['riskStatus'] as String? ?? 'Normal',
        isActive: map['isActive'] as bool? ?? true,
        inactiveReason: map['inactiveReason'] as String?,
        linkedChildIds: (map['linkedChildIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

  Mother copyWith({
    List<String>? linkedChildIds,
    String? riskStatus,
    String? breastfeedingPractice,
    bool? isActive,
    String? inactiveReason,
  }) =>
      Mother(
        id: id,
        fullName: fullName,
        birthDate: birthDate,
        contactNo: contactNo,
        address: address,
        barangay: barangay,
        breastfeedingPractice: breastfeedingPractice ?? this.breastfeedingPractice,
        belongsToIpGroup: belongsToIpGroup,
        disability: disability,
        createdAt: createdAt,
        riskStatus: riskStatus ?? this.riskStatus,
        isActive: isActive ?? this.isActive,
        inactiveReason: inactiveReason ?? this.inactiveReason,
        linkedChildIds: linkedChildIds ?? this.linkedChildIds,
      );

  String get ageLabel => '$age yrs. old';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}