class ActivityLogEntry {
  final String type;
  final String title;
  final DateTime timestamp;

  const ActivityLogEntry({
    required this.type,
    required this.title,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ActivityLogEntry.fromMap(Map<dynamic, dynamic> map) => ActivityLogEntry(
        type: map['type'] as String,
        title: map['title'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}