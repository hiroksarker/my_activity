// Manual JSON serialization for now

enum AlertType {
  delay,
  gateChange,
  weather,
  reminder,
  cancellation,
  update
}

enum AlertPriority {
  low,
  medium,
  high,
  critical
}

class TravelAlert {
  final String id;
  final String activityId;
  final AlertType type;
  final AlertPriority priority;
  final String title;
  final String message;
  final Map<String, dynamic> actionData;
  final bool isRead;
  final bool isDismissed;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final String userId;

  const TravelAlert({
    required this.id,
    required this.activityId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.actionData,
    required this.isRead,
    required this.isDismissed,
    required this.timestamp,
    this.expiresAt,
    required this.userId,
  });

  factory TravelAlert.fromJson(Map<String, dynamic> json) {
    return TravelAlert(
      id: json['id'] ?? '',
      activityId: json['activityId'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.update,
      ),
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AlertPriority.medium,
      ),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actionData: Map<String, dynamic>.from(json['actionData'] ?? {}),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'message': message,
      'actionData': actionData,
      'isRead': isRead,
      'isDismissed': isDismissed,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'userId': userId,
    };
  }

  TravelAlert copyWith({
    String? id,
    String? activityId,
    AlertType? type,
    AlertPriority? priority,
    String? title,
    String? message,
    Map<String, dynamic>? actionData,
    bool? isRead,
    bool? isDismissed,
    DateTime? timestamp,
    DateTime? expiresAt,
    String? userId,
  }) {
    return TravelAlert(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      actionData: actionData ?? this.actionData,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
    );
  }

  // Helper methods
  bool get isActive => !isDismissed && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isCritical => priority == AlertPriority.critical;
  
  String get priorityDisplayName {
    switch (priority) {
      case AlertPriority.low:
        return 'Low';
      case AlertPriority.medium:
        return 'Medium';
      case AlertPriority.high:
        return 'High';
      case AlertPriority.critical:
        return 'Critical';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case AlertType.delay:
        return 'Delay';
      case AlertType.gateChange:
        return 'Gate Change';
      case AlertType.weather:
        return 'Weather Alert';
      case AlertType.reminder:
        return 'Reminder';
      case AlertType.cancellation:
        return 'Cancellation';
      case AlertType.update:
        return 'Update';
    }
  }
}