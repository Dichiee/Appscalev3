class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'referral_completed', 'referral_update', 'general'
  final String? referralId;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referralId,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? referralId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referralId: referralId ?? this.referralId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'referralId': referralId,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromMap(Map<dynamic, dynamic> map) => AppNotification(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        type: map['type'] as String,
        referralId: map['referralId'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isRead: map['isRead'] as bool? ?? false,
      );
}
