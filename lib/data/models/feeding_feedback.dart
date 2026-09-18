class FeedingFeedback {
  final String id;
  final DateTime date;
  final String note;
  final String? tag; // 'Went well' or 'Needs improvement' — a field
                      // observation only, never rolled into a percentage.
  final String barangay;

  const FeedingFeedback({required this.id, required this.date, required this.note, this.tag, required this.barangay});

  Map<String, dynamic> toMap() => {'id': id, 'date': date.toIso8601String(), 'note': note, 'tag': tag, 'barangay': barangay};

  factory FeedingFeedback.fromMap(Map<String, dynamic> map) => FeedingFeedback(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String,
        tag: map['tag'] as String?,
        barangay: map['barangay'] as String,
      );
}