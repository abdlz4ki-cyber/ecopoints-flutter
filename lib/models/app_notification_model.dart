import 'dart:convert';

enum NotificationType { deposit, reward, general }

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? referenceId;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.referenceId,
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? referenceId,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'referenceId': referenceId,
    };
  }

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    NotificationType parsedType = NotificationType.general;
    final typeStr = map['type'] as String? ?? 'general';
    if (typeStr == 'deposit') {
      parsedType = NotificationType.deposit;
    } else if (typeStr == 'reward') {
      parsedType = NotificationType.reward;
    }

    DateTime parsedTime = DateTime.now();
    if (map['timestamp'] != null) {
      try {
        parsedTime = DateTime.parse(map['timestamp'] as String);
      } catch (_) {}
    }

    return AppNotificationModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? 'EcoPoints',
      body: map['body'] as String? ?? '',
      type: parsedType,
      timestamp: parsedTime,
      isRead: map['isRead'] as bool? ?? false,
      referenceId: map['referenceId'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppNotificationModel.fromJson(String source) =>
      AppNotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
