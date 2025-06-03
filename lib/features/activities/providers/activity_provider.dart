import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/activity_history.dart';
import '../models/activity_enums.dart';

class ActivityProvider extends ChangeNotifier {
  final _logger = Logger();
  final Database _database;
  final _uuid = const Uuid();
  List<Activity> _activities = [];
  List<ActivityHistory> _history = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  ActivityProvider(this._database) {
    _init();
  }

  bool get hasInitialized => _hasInitialized;
  List<Activity> get activities => _activities;
  List<ActivityHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    _loadActivities();
    _loadHistory();
    _hasInitialized = true;
  }

  Future<void> _loadActivities() async {
    try {
      _isLoading = true;
      notifyListeners();

      final List<Map<String, dynamic>> activities = await _database.query(
        'activities',
        orderBy: 'createdAt DESC',
      );

      _activities = activities.map((map) => Activity.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _logger.e('Error loading activities', error: e);
      _error = 'Failed to load activities';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHistory() async {
    try {
      final List<Map<String, dynamic>> history = await _database.query(
        'activity_history',
        orderBy: 'timestamp DESC',
      );
      _history = history.map((map) => ActivityHistory.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error loading history', error: e);
      _error = 'Failed to load history';
    }
  }

  Future<Activity> addActivity({
    required String title,
    required String description,
    required String category,
    required ActivityType type,
    required ActivityStatus status,
    ActivityPriority priority = ActivityPriority.regular,
    String? recurrenceType,
    DateTime? nextOccurrence,
    DateTime? timestamp,
  }) async {
    final now = DateTime.now();
    final activity = Activity(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      type: type,
      status: status,
      priority: priority,
      timestamp: timestamp ?? now,
      createdAt: now,
      updatedAt: now,
      recurrenceType: recurrenceType,
      nextOccurrence: nextOccurrence,
    );

    try {
      await _database.insert(
        'activities',
        activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await ActivityHistory.addEntry(
        _database,
        activity,
        'created',
        'Activity created',
      );

      _activities.add(activity);
      notifyListeners();
      return activity;
    } catch (e) {
      _logger.e('Error adding activity', error: e);
      _error = 'Failed to add activity';
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      final oldActivity = _activities.firstWhere((a) => a.id == activity.id);
      
      await _database.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );

      await ActivityHistory.addEntry(
        _database,
        activity,
        'updated',
        'Activity updated',
        previousActivity: oldActivity,
      );

      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error updating activity', error: e);
      _error = 'Failed to update activity';
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      final activity = _activities.firstWhere((a) => a.id == id);
      
      await _database.delete(
        'activities',
        where: 'id = ?',
        whereArgs: [id],
      );

      await ActivityHistory.addEntry(
        _database,
        activity,
        'deleted',
        'Activity deleted',
      );

      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _logger.e('Error deleting activity', error: e);
      _error = 'Failed to delete activity';
      rethrow;
    }
  }

  Future<void> updateActivityStatus(String id, ActivityStatus status) async {
    try {
      final activity = _activities.firstWhere((a) => a.id == id);
      final updatedActivity = activity.copyWith(status: status);
      await updateActivity(updatedActivity);
    } catch (e) {
      _logger.e('Error updating activity status', error: e);
      _error = 'Failed to update activity status';
      rethrow;
    }
  }

  Future<void> updateActivityPriority(String id, ActivityPriority priority) async {
    try {
      final activity = _activities.firstWhere((a) => a.id == id);
      final updatedActivity = activity.copyWith(priority: priority);
      await updateActivity(updatedActivity);
    } catch (e) {
      _logger.e('Error updating activity priority', error: e);
      _error = 'Failed to update activity priority';
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesByType(ActivityType type) async {
    return _activities.where((a) => a.type == type).toList();
  }

  Future<List<Activity>> getActivitiesByStatus(ActivityStatus status) async {
    return _activities.where((a) => a.status == status).toList();
  }

  Future<List<Activity>> getActivitiesByCategory(String category) async {
    return _activities.where((a) => a.category == category).toList();
  }

  Future<List<Activity>> getActivitiesByPriority(ActivityPriority priority) async {
    return _activities.where((a) => a.priority == priority).toList();
  }

  Future<List<Activity>> searchActivities(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _activities.where((activity) {
      return activity.title.toLowerCase().contains(lowercaseQuery) ||
          activity.description.toLowerCase().contains(lowercaseQuery) ||
          activity.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> fetchActivities() async {
    await _loadActivities();
  }

  Future<List<ActivityHistory>> getActivityHistory(String? activityId) async {
    try {
      final List<Map<String, dynamic>> history = await _database.query(
        'activity_history',
        where: activityId != null ? 'activityId = ?' : null,
        whereArgs: activityId != null ? [activityId] : null,
        orderBy: 'timestamp DESC',
      );
      return history.map((map) => ActivityHistory.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error loading activity history', error: e);
      _error = 'Failed to load activity history';
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 