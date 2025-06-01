import 'package:flutter/material.dart';
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
  final String changeType;
  final String? changeDescription;
  final DateTime timestamp;
  final Activity? newActivity;
  final Activity? previousActivity;

  ActivityHistory({
    String? id,
    required this.activityId,
    required this.changeType,
    this.changeDescription,
    DateTime? timestamp,
    this.newActivity,
    this.previousActivity,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  String get displayText {
    switch (changeType) {
      case 'Created':
        return 'Created new transaction: ${newActivity?.title}';
      case 'Updated':
        return changeDescription ?? 'Updated transaction: ${newActivity?.title}';
      case 'Deleted':
        return 'Deleted transaction: ${previousActivity?.title}';
      default:
        return 'Unknown change: ${newActivity?.title ?? previousActivity?.title}';
    }
  }

  IconData get icon {
    switch (changeType) {
      case 'Created':
        return Icons.add_circle;
      case 'Updated':
        return Icons.edit;
      case 'Deleted':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (changeType) {
      case 'Created':
        return Colors.green;
      case 'Updated':
        return Colors.blue;
      case 'Deleted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  factory ActivityHistory.fromMap(Map<String, dynamic> map) {
    return ActivityHistory(
      id: map['id'] as String,
      activityId: map['activityId'] as String,
      changeType: map['changeType'] as String,
      changeDescription: map['changeDescription'] as String?,
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp'] as DateTime
          : DateTime.parse(map['timestamp'] as String),
      newActivity: map['newActivity'] != null
          ? Activity.fromMap(map['newActivity'] as Map<String, dynamic>)
          : null,
      previousActivity: map['previousActivity'] != null
          ? Activity.fromMap(map['previousActivity'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'timestamp': timestamp.toIso8601String(),
      'changeType': changeType,
      'changeDescription': changeDescription,
      'newActivity': newActivity?.toMap(),
      'previousActivity': previousActivity?.toMap(),
    };
  }

  @override
  String toString() {
    return 'ActivityHistory(id: $id, activityId: $activityId, changeType: $changeType)';
  }

  factory ActivityHistory.create({
    required String activityId,
    required String changeType,
    Activity? previousActivity,
    Activity? newActivity,
    String? changeDescription,
  }) {
    return ActivityHistory(
      activityId: activityId,
      changeType: changeType,
      previousActivity: previousActivity,
      newActivity: newActivity,
      changeDescription: changeDescription,
    );
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
      changeType: action.toString().split('.').last,
      previousActivity: previousActivity,
      newActivity: newActivity,
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
        return 'Created new transaction: ${newActivity?.title}';
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
        return 'Deleted transaction: ${previousActivity?.title}';
    }
  }
} 