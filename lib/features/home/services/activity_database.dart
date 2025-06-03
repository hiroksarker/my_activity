import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_history.dart';
import '../../activities/models/activity_enums.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class ActivityDatabase {
  final Database _database;
  final _logger = Logger();

  ActivityDatabase(this._database);

  Future<void> createTables() async {
    try {
      await _database.execute('''
        CREATE TABLE IF NOT EXISTS activities (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          amount REAL,
          category TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          transactionType TEXT NOT NULL,
          isRecurring INTEGER NOT NULL DEFAULT 0,
          recurrenceType TEXT,
          nextOccurrence TEXT,
          recurrenceRule TEXT,
          metadata TEXT,
          dueDate TEXT,
          taskStatus TEXT NOT NULL,
          taskType TEXT NOT NULL,
          priority INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await _database.execute('''
        CREATE TABLE IF NOT EXISTS activity_history (
          id TEXT PRIMARY KEY,
          activityId TEXT NOT NULL,
          changeType TEXT NOT NULL,
          changeDescription TEXT,
          timestamp TEXT NOT NULL,
          newActivity TEXT,
          previousActivity TEXT,
          FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
        )
      ''');
    } catch (e, stackTrace) {
      _logger.e('Failed to create tables', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> insertActivity(Activity activity) async {
    try {
      await _database.insert(
        'activities',
        activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to insert activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      await _database.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to update activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _database.delete(
        'activities',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to delete activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Activity>> getActivities() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query('activities');
      return maps.map((map) => Activity.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get activities', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesByDateRange(DateTime start, DateTime end) async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query(
        'activities',
        where: 'createdAt BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
      );
      return maps.map((map) => Activity.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get activities by date range', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesByCategory(String category) async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query(
        'activities',
        where: 'category = ?',
        whereArgs: [category],
      );
      return maps.map((map) => Activity.fromMap(map)).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get activities by category', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addToHistory(Activity activity, String changeType, {String? changeDescription}) async {
    try {
      await _database.insert(
        'activity_history',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'activityId': activity.id,
          'changeType': changeType,
          'changeDescription': changeDescription ?? 'Activity ${changeType.toLowerCase()}',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to add to history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<ActivityHistory>> getActivityHistory() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query(
        'activity_history',
        orderBy: 'timestamp DESC',
      );
      
      return maps.map((map) => ActivityHistory(
        id: map['id'] as String,
        activityId: map['activityId'] as String,
        changeType: map['changeType'] as String,
        changeDescription: map['changeDescription'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
      )).toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get activity history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 