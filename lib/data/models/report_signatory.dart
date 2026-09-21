class ReportSignatory {
  final String barangay;
  final String bnsName;
  final String punongBarangayName;
  final String mnaoAdminAideName;
  final String dnpcName;

  const ReportSignatory({
    required this.barangay,
    required this.bnsName,
    required this.punongBarangayName,
    required this.mnaoAdminAideName,
    required this.dnpcName,
  });

  Map<String, dynamic> toMap() => {
        'barangay': barangay,
        'bnsName': bnsName,
        'punongBarangayName': punongBarangayName,
        'mnaoAdminAideName': mnaoAdminAideName,
        'dnpcName': dnpcName,
      };

  factory ReportSignatory.fromMap(Map<String, dynamic> map) => ReportSignatory(
        barangay: map['barangay'] as String,
        bnsName: map['bnsName'] as String,
        punongBarangayName: map['punongBarangayName'] as String,
        mnaoAdminAideName: map['mnaoAdminAideName'] as String,
        dnpcName: map['dnpcName'] as String,
      );
}