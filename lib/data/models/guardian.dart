class Guardian {
  final String fullName;
  final String relationship;
  final String contactNo;
  final String? linkedMotherId; // set only if guardian is also a monitored mother

  const Guardian({
    required this.fullName,
    required this.relationship,
    required this.contactNo,
    this.linkedMotherId,
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'relationship': relationship,
        'contactNo': contactNo,
        'linkedMotherId': linkedMotherId,
      };

  factory Guardian.fromMap(Map map) => Guardian(
        fullName: map['fullName'] as String,
        relationship: map['relationship'] as String,
        contactNo: map['contactNo'] as String,
        linkedMotherId: map['linkedMotherId'] as String?,
      );
}