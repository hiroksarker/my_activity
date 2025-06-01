import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/activity_history.dart';
import '../services/activity_database.dart';
import 'package:sqflite/sqflite.dart';

class ActivityProvider with ChangeNotifier {
  final Database _database;
  final _logger = Logger();
  final _uuid = const Uuid();
  List<Activity> _activities = [];
  List<ActivityHistory> _history = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  ActivityProvider(this._database) {
    _initDatabase();
  }

  List<Activity> get activities => _activities;
  List<ActivityHistory> get history => _history;
  List<Activity> get expenses => _activities.where((a) => a.amount != null && a.amount! < 0).toList();
  List<Activity> get income => _activities.where((a) => a.amount != null && a.amount! > 0).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> _initDatabase() async {
    try {
      final db = ActivityDatabase(_database);
      await db.createTables();
      await _loadActivities();
      await _loadHistory();
      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _loadActivities() async {
    try {
      final db = ActivityDatabase(_database);
      _activities = await db.getActivities();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Failed to load activities', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _loadHistory() async {
    try {
      final db = ActivityDatabase(_database);
      _history = await db.getActivityHistory();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Failed to load history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final db = ActivityDatabase(_database);
      final newActivity = activity.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insertActivity(newActivity);
      await _addToHistory(newActivity, 'Created');
      await _loadActivities();
    } catch (e, stackTrace) {
      _logger.e('Failed to add activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      final db = ActivityDatabase(_database);
      final oldActivity = _activities.firstWhere((a) => a.id == activity.id);
      
      String changeDescription = '';
      if (oldActivity.amount != activity.amount) {
        changeDescription = 'Amount updated from \$${oldActivity.amount?.toStringAsFixed(2)} to \$${activity.amount?.toStringAsFixed(2)}';
      } else if (oldActivity.description != activity.description) {
        changeDescription = 'Description updated from "${oldActivity.description}" to "${activity.description}"';
      } else if (oldActivity.category != activity.category) {
        changeDescription = 'Category updated from "${oldActivity.category}" to "${activity.category}"';
      }

      final updatedActivity = activity.copyWith(
        updatedAt: DateTime.now(),
      );

      await db.updateActivity(updatedActivity);
      if (changeDescription.isNotEmpty) {
        await _addToHistory(updatedActivity, changeDescription);
      }
      await _loadActivities();
    } catch (e, stackTrace) {
      _logger.e('Failed to update activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      final db = ActivityDatabase(_database);
      final activity = _activities.firstWhere((a) => a.id == id);
      
      await db.deleteActivity(id);
      await _addToHistory(activity, 'Deleted');
      await _loadActivities();
    } catch (e, stackTrace) {
      _logger.e('Failed to delete activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _addToHistory(Activity activity, String changeType) async {
    try {
      final db = ActivityDatabase(_database);
      await db.addToHistory(activity, changeType);
      await _loadHistory();
    } catch (e, stackTrace) {
      _logger.e('Failed to add to history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesByDateRange(DateTime start, DateTime end) async {
    try {
      final db = ActivityDatabase(_database);
      return await db.getActivitiesByDateRange(start, end);
    } catch (e, stackTrace) {
      _logger.e('Failed to get activities by date range', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Activity>> getActivitiesByCategory(String category) async {
    try {
      final db = ActivityDatabase(_database);
      return await db.getActivitiesByCategory(category);
    } catch (e, stackTrace) {
      _logger.e('Failed to get activities by category', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<double> getTotalExpenses(DateTime? start, DateTime? end) async {
    try {
      final activities = start != null && end != null
          ? await getActivitiesByDateRange(start, end)
          : _activities;
      double total = 0.0;
      for (final activity in activities.where((a) => a.amount != null && a.amount! < 0)) {
        total += (activity.amount ?? 0).abs();
      }
      return total;
    } catch (e, stackTrace) {
      _logger.e('Failed to get total expenses', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<double> getTotalIncome(DateTime? start, DateTime? end) async {
    try {
      final activities = start != null && end != null
          ? await getActivitiesByDateRange(start, end)
          : _activities;
      double total = 0.0;
      for (final activity in activities.where((a) => a.amount != null && a.amount! > 0)) {
        total += (activity.amount ?? 0);
      }
      return total;
    } catch (e, stackTrace) {
      _logger.e('Failed to get total income', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<double> getNetIncome(DateTime? start, DateTime? end) async {
    final income = await getTotalIncome(start, end);
    final expenses = await getTotalExpenses(start, end);
    return income - expenses;
  }

  Future<Map<String, double>> getIncomeBySource(DateTime? start, DateTime? end) async {
    final activities = start != null && end != null
        ? await getActivitiesByDateRange(start, end)
        : _activities;
    
    final Map<String, double> result = {};
    for (final activity in activities.where((a) => a.amount != null && a.amount! > 0)) {
      result[activity.category] = (result[activity.category] ?? 0) + (activity.amount ?? 0);
    }
    return result;
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime? start, DateTime? end) async {
    final activities = start != null && end != null
        ? await getActivitiesByDateRange(start, end)
        : _activities;
    
    final Map<String, double> result = {};
    for (final activity in activities.where((a) => a.amount != null && a.amount! < 0)) {
      result[activity.category] = (result[activity.category] ?? 0) + (activity.amount ?? 0).abs();
    }
    return result;
  }

  Future<List<Activity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final activities = await getActivitiesByDateRange(start, end);
    // Only include financial transactions (not tasks)
    return activities.where((a) =>
      a.type == ActivityType.expense || a.type == ActivityType.income
    ).toList();
  }

  Future<List<ActivityHistory>> getActivityHistory(String? activityId) async {
    if (activityId == null) return _history;
    return _history.where((h) => h.activityId == activityId).toList();
  }

  List<Activity> searchActivities(String query) {
    if (query.isEmpty) return _activities;
    
    final lowercaseQuery = query.toLowerCase();
    return _activities
        .where((activity) =>
            activity.title.toLowerCase().contains(lowercaseQuery) ||
            activity.description.toLowerCase().contains(lowercaseQuery) ||
            activity.category.toLowerCase().contains(lowercaseQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    if (!_isInitialized) {
      await _initDatabase();
      return;
    }

    try {
      _setLoading(true);
      _error = null;
      await _loadActivities();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final recurringActivities = _activities.where((a) =>
      a.isRecurring &&
      a.nextOccurrence != null &&
      a.nextOccurrence!.isBefore(now) &&
      a.status == ActivityStatus.active
    ).toList();

    for (final activity in recurringActivities) {
      final nextOccurrence = activity.getNextOccurrence();
      if (nextOccurrence == null) continue;

      // Create a new transaction for the current period
      final newActivity = activity.copyWith(
        id: _uuid.v4(),
        createdAt: now,
        nextOccurrence: nextOccurrence,
      );

      // Update the original transaction with the next occurrence date
      final updatedActivity = activity.copyWith(
        nextOccurrence: nextOccurrence,
      );

      await _database.transaction((txn) async {
        await txn.insert(
          'activities',
          newActivity.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.update(
          'activities',
          updatedActivity.toMap(),
          where: 'id = ?',
          whereArgs: [activity.id],
        );
      });

      _activities.add(newActivity);
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }
    }

    notifyListeners();
  }
} 