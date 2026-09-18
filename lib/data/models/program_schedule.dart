class ProgramSchedule {
  final String id;
  final String title;
  final String programType; // 'Feeding', 'Vitamin A', 'Deworming', 'OPT Plus'
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final String targetGroup;
  final String notes;
  final String barangay;
  final String createdBy; // 'BNS Mobile', 'RHU Web Admin', 'BHW'
  final DateTime createdAt;

  const ProgramSchedule({
    required this.id,
    required this.title,
    required this.programType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.targetGroup,
    this.notes = '',
    required this.barangay,
    this.createdBy = 'BNS Mobile',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'programType': programType,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'location': location,
        'targetGroup': targetGroup,
        'notes': notes,
        'barangay': barangay,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProgramSchedule.fromMap(Map<dynamic, dynamic> map) => ProgramSchedule(
        id: map['id'] as String,
        title: map['title'] as String,
        programType: map['programType'] as String,
        date: DateTime.parse(map['date'] as String),
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
        location: map['location'] as String,
        targetGroup: map['targetGroup'] as String,
        notes: map['notes'] as String? ?? '',
        barangay: map['barangay'] as String,
        createdBy: map['createdBy'] as String? ?? 'BNS Mobile',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
