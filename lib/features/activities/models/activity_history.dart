import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'activity.dart';
import 'activity_enums.dart';
import 'package:sqflite/sqflite.dart';

enum HistoryAction {
  created,
  updated,
  deleted,
  statusChanged,
}

class ActivityHistory {
  final String id;
  final String activityId;
  final String action;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? changes;
  final Activity? previousActivity;

  ActivityHistory({
    required this.id,
    required this.activityId,
    required this.action,
    required this.description,
    required this.timestamp,
    this.changes,
    this.previousActivity,
  });

  String get displayText {
    final activityType = previousActivity?.type;
    final typeStr = activityType?.toString().split('.').last.toLowerCase() ?? 'activity';
    
    switch (action.toLowerCase()) {
      case 'created':
        return 'Created new $typeStr: ${previousActivity?.title}';
      case 'updated':
        return description;
      case 'deleted':
        return 'Deleted $typeStr: ${previousActivity?.title}';
      case 'statuschanged':
        if (previousActivity != null) {
          final oldStatus = previousActivity?.status.toString().split('.').last;
          final newStatus = previousActivity?.status.toString().split('.').last;
          return 'Changed status of $typeStr from $oldStatus to $newStatus';
        }
        return 'Changed status: ${previousActivity?.title}';
      default:
        return 'Unknown change: ${previousActivity?.title}';
    }
  }

  IconData get icon {
    switch (action.toLowerCase()) {
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      case 'statuschanged':
        return Icons.change_circle;
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (action.toLowerCase()) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'deleted':
        return Colors.red;
      case 'statuschanged':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'action': action.toLowerCase(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'changes': changes != null ? json.encode(changes) : null,
    };
  }

  factory ActivityHistory.fromMap(Map<String, dynamic> map) {
    return ActivityHistory(
      id: map['id'] as String,
      activityId: map['activityId'] as String,
      action: map['action'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      changes: map['changes'] != null
          ? Map<String, dynamic>.from(json.decode(map['changes'] as String))
          : null,
      previousActivity: null,
    );
  }

  @override
  String toString() {
    return 'ActivityHistory(id: $id, activityId: $activityId, action: $action)';
  }

  static Future<void> addEntry(
    Database database,
    Activity activity,
    String action,
    String description, {
    Activity? previousActivity,
  }) async {
    final changes = <String>[];
    if (previousActivity != null) {
      if (previousActivity.title != activity.title) {
        changes.add('title from "${previousActivity.title}" to "${activity.title}"');
      }
      if (previousActivity.description != activity.description) {
        changes.add('description from "${previousActivity.description}" to "${activity.description}"');
      }
      if (previousActivity.category != activity.category) {
        changes.add('category from "${previousActivity.category}" to "${activity.category}"');
      }
      if (previousActivity.type != activity.type) {
        changes.add('type from ${previousActivity.type} to ${activity.type}');
      }
      if (previousActivity.status != activity.status) {
        changes.add('status from ${previousActivity.status} to ${activity.status}');
      }
      if (previousActivity.priority != activity.priority) {
        changes.add('priority from ${previousActivity.priority} to ${activity.priority}');
      }
      if (previousActivity.recurrenceType != activity.recurrenceType) {
        changes.add('recurrence type from ${previousActivity.recurrenceType} to ${activity.recurrenceType}');
      }
      if (previousActivity.nextOccurrence != activity.nextOccurrence) {
        changes.add('next occurrence from ${previousActivity.nextOccurrence} to ${activity.nextOccurrence}');
      }
    }

    final history = ActivityHistory(
      id: const Uuid().v4(),
      activityId: activity.id,
      action: action.toLowerCase(),
      description: description,
      timestamp: DateTime.now(),
      changes: changes.isNotEmpty ? {'changes': changes.join(', ')} : null,
      previousActivity: previousActivity,
    );

    await database.insert('activity_history', history.toMap());
  }
} 