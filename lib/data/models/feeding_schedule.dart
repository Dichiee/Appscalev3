class FeedingSchedule {
  final List<int> daysOfWeek; // DateTime.monday=1 ... sunday=7
  final String startTime;
  final String endTime;
  final String location;
  final DateTime startDate;
  final DateTime? endDate; // null = ongoing
  final String barangay;
  final DateTime createdAt;

  const FeedingSchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.barangay,
    required this.createdAt,
  });

  static const _dayLabels = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
  String get daysSummary {
    final sorted = [...daysOfWeek]..sort();
    return sorted.map((d) => _dayLabels[d]).join(', ');
  }

  Map<String, dynamic> toMap() => {
        'daysOfWeek': daysOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'barangay': barangay,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) => FeedingSchedule(
        daysOfWeek: (map['daysOfWeek'] as List).map((e) => e as int).toList(),
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
        location: map['location'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
        barangay: map['barangay'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}