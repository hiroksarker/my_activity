class ActivityHistory {
  final String id;
  final String activityId;
  final String changeType;
  final String? changeDescription;
  final DateTime timestamp;

  ActivityHistory({
    required this.id,
    required this.activityId,
    required this.changeType,
    this.changeDescription,
    required this.timestamp,
  });

  factory ActivityHistory.fromMap(Map<String, dynamic> map) {
    return ActivityHistory(
      id: map['id'] as String,
      activityId: map['activityId'] as String,
      changeType: map['changeType'] as String,
      changeDescription: map['changeDescription'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'changeType': changeType,
      'changeDescription': changeDescription,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 