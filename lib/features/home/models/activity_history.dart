import 'package:uuid/uuid.dart';
import 'activity.dart';

enum HistoryAction {
  created,
  updated,
  deleted,
  statusChanged,
}

class ActivityHistory {
  final String id;
  final String activityId;
  final DateTime timestamp;
  final HistoryAction action;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String changeDescription;

  ActivityHistory({
    String? id,
    required this.activityId,
    DateTime? timestamp,
    required this.action,
    this.previousState,
    this.newState,
    required this.changeDescription,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      timestamp: json['timestamp'] is DateTime 
          ? json['timestamp'] as DateTime 
          : DateTime.parse(json['timestamp'] as String),
      action: HistoryAction.values.firstWhere(
        (e) => e.toString().split('.').last == json['action'],
        orElse: () => HistoryAction.updated,
      ),
      previousState: json['previousState'] as Map<String, dynamic>?,
      newState: json['newState'] as Map<String, dynamic>?,
      changeDescription: json['changeDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'timestamp': timestamp.toIso8601String(),
      'action': action.toString().split('.').last,
      'previousState': previousState,
      'newState': newState,
      'changeDescription': changeDescription,
    };
  }

  @override
  String toString() {
    return 'ActivityHistory(id: $id, activityId: $activityId, action: $action)';
  }

  static ActivityHistory fromActivityChange({
    required String activityId,
    required HistoryAction action,
    Activity? previousActivity,
    Activity? newActivity,
    String? changeDescription,
  }) {
    return ActivityHistory(
      activityId: activityId,
      action: action,
      previousState: previousActivity?.toJson(),
      newState: newActivity?.toJson(),
      changeDescription: changeDescription ?? _generateChangeDescription(
        action,
        previousActivity,
        newActivity,
      ),
    );
  }

  static String _generateChangeDescription(
    HistoryAction action,
    Activity? previousActivity,
    Activity? newActivity,
  ) {
    switch (action) {
      case HistoryAction.created:
        return 'Created new ${newActivity?.type == ActivityType.task ? 'task' : 'expense'}: ${newActivity?.title}';
      
      case HistoryAction.updated:
        if (previousActivity == null || newActivity == null) return 'Updated activity';
        final changes = <String>[];
        
        if (previousActivity.title != newActivity.title) {
          changes.add('title from "${previousActivity.title}" to "${newActivity.title}"');
        }
        if (previousActivity.description != newActivity.description) {
          changes.add('description');
        }
        if (previousActivity.category != newActivity.category) {
          changes.add('category from "${previousActivity.category}" to "${newActivity.category}"');
        }
        if (previousActivity.amount != newActivity.amount) {
          changes.add('amount from \$${previousActivity.amount} to \$${newActivity.amount}');
        }
        
        return 'Updated ${changes.join(', ')}';
      
      case HistoryAction.statusChanged:
        if (previousActivity == null || newActivity == null) return 'Changed status';
        return 'Changed status from ${previousActivity.status} to ${newActivity.status}';
      
      case HistoryAction.deleted:
        return 'Deleted ${previousActivity?.type == ActivityType.task ? 'task' : 'expense'}: ${previousActivity?.title}';
    }
  }
} 