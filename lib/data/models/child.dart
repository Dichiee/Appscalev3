import 'guardian.dart';

class Child {
  final String id;
  final String sequenceNo;
  final String fullName;
  final DateTime birthDate;
  final String gender;
  final String address;
  final String barangay;
  final bool belongsToIpGroup;
  final String disability;
  final Guardian guardian;
  final DateTime createdAt;
  final String nutritionStatus; // 'Normal', 'Underweight', 'Severely Underweight', 'Overweight', 'Obese', 'Stunted', 'Not weighed'
  final String stuntingStatus; // 'Normal', 'Stunted', 'Severely Stunted', 'Not weighed'
  final DateTime? lastWeighedAt;
  final bool isActive;
  final String? inactiveReason; // 'Graduated', 'Transferred', 'Deceased'
  final String wastingStatus; // 'SAM', 'MAM', 'Normal', 'Overweight', 'Obese', 'Not weighed'

   const Child({
    required this.id,
    required this.sequenceNo,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.barangay,
    required this.belongsToIpGroup,
    required this.disability,
    required this.guardian,
    required this.createdAt,
    this.nutritionStatus = 'Not weighed',
    this.stuntingStatus = 'Not weighed',
    this.lastWeighedAt,
    this.isActive = true,
    this.inactiveReason,
    this.wastingStatus = 'Not weighed',
  });

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

    /// "2 yr. 4 mo." for a profile header, vs the shorter "28 mos" used in list rows.
  String get ageLabel {
    final months = ageInMonths;
    if (months < 12) return '$months mo.';
    final years = months ~/ 12;
    final remainder = months % 12;
    return '$years yr. $remainder mo.';
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sequenceNo': sequenceNo,
        'fullName': fullName,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'address': address,
        'barangay': barangay,
        'belongsToIpGroup': belongsToIpGroup,
        'disability': disability,
        'guardian': guardian.toMap(),
        'createdAt': createdAt.toIso8601String(),
        'nutritionStatus': nutritionStatus,
        'stuntingStatus': stuntingStatus,
        'lastWeighedAt': lastWeighedAt?.toIso8601String(),
        'isActive': isActive,
        'inactiveReason': inactiveReason,
        'wastingStatus': wastingStatus,
      };

  factory Child.fromMap(Map map) => Child(
        id: map['id'] as String,
        sequenceNo: map['sequenceNo'] as String,
        fullName: map['fullName'] as String,
        birthDate: DateTime.parse(map['birthDate'] as String),
        gender: map['gender'] as String,
        address: map['address'] as String,
        barangay: map['barangay'] as String,
        belongsToIpGroup: map['belongsToIpGroup'] as bool,
        disability: map['disability'] as String,
        guardian: Guardian.fromMap(map['guardian'] as Map),
        createdAt: DateTime.parse(map['createdAt'] as String),
        nutritionStatus: map['nutritionStatus'] as String? ?? 'Not weighed',
        stuntingStatus: map['stuntingStatus'] as String? ?? 'Not weighed',
        lastWeighedAt: map['lastWeighedAt'] != null ? DateTime.parse(map['lastWeighedAt'] as String) : null,
        isActive: map['isActive'] as bool? ?? true,
        inactiveReason: map['inactiveReason'] as String?,
        wastingStatus: map['wastingStatus'] as String? ?? 'Not weighed',
      );

  Child copyWith({
    Guardian? guardian,
    String? nutritionStatus,
    String? stuntingStatus,
    String? wastingStatus,
    DateTime? lastWeighedAt,
    bool? isActive,
    String? inactiveReason,
  }) =>
      Child(
        id: id,
        sequenceNo: sequenceNo,
        fullName: fullName,
        birthDate: birthDate,
        gender: gender,
        address: address,
        barangay: barangay,
        belongsToIpGroup: belongsToIpGroup,
        disability: disability,
        guardian: guardian ?? this.guardian,
        createdAt: createdAt,
        nutritionStatus: nutritionStatus ?? this.nutritionStatus,
        lastWeighedAt: lastWeighedAt ?? this.lastWeighedAt,
        isActive: isActive ?? this.isActive,
        inactiveReason: inactiveReason ?? this.inactiveReason,
        stuntingStatus: stuntingStatus ?? this.stuntingStatus,
        wastingStatus: wastingStatus ?? this.wastingStatus,
      );
}