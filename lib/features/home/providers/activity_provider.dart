import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../shared/services/firebase_service.dart';
import 'package:logger/logger.dart';
import '../models/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/activity_history.dart';
import '../services/activity_database.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityDatabase _database;
  List<Activity> _activities = [];
  List<ActivityHistory> _history = [];
  bool _isLoading = false;
  String? _error;
  static const String _storageKey = 'activities';

  ActivityProvider(this._database) {
    _loadActivities();
  }

  List<Activity> get activities => List.from(_activities);
  List<ActivityHistory> get history => List.from(_history);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadActivities() async {
    _setLoading(true);
    try {
      final activities = await _database.getActivities();
      final history = await _database.getActivityHistory();
      _activities = activities;
      _history = history;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching activities from database...');
      final activities = await _database.getActivities();
      print('Fetched ${activities.length} activities');
      
      _activities = activities;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching activities: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      print('Adding activity: ${activity.toString()}');
      await _database.insertActivity(activity);
      
      // Add to history
      final history = ActivityHistory(
        activityId: activity.id,
        action: HistoryAction.created,
        newState: activity.toMap(),
        changeDescription: 'Activity created',
      );
      await _database.insertActivityHistory(history);
      
      print('Activity added successfully, refreshing list...');
      await fetchActivities();
    } catch (e) {
      print('Error adding activity: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      print('Updating activity: ${activity.toString()}');
      
      // Get the old activity state before updating
      final oldActivity = _activities.firstWhere(
        (a) => a.id == activity.id,
        orElse: () => throw Exception('Activity not found: ${activity.id}'),
      );
      
      // Determine what changed
      final isStatusChange = oldActivity.status != activity.status;
      final isAmountChange = oldActivity.amount != activity.amount;
      final isTypeChange = oldActivity.type != activity.type;
      
      // Update the activity in the database
      await _database.updateActivity(activity);
      
      // Create appropriate history entry
      String changeDescription;
      HistoryAction action;
      
      if (isStatusChange) {
        action = HistoryAction.statusChanged;
        changeDescription = 'Status changed from ${oldActivity.status.toString().split('.').last} to ${activity.status.toString().split('.').last}';
      } else if (isAmountChange) {
        action = HistoryAction.updated;
        changeDescription = 'Amount updated from \$${oldActivity.amount.toStringAsFixed(2)} to \$${activity.amount.toStringAsFixed(2)}';
      } else if (isTypeChange) {
        action = HistoryAction.updated;
        changeDescription = 'Type changed from ${oldActivity.type.toString().split('.').last} to ${activity.type.toString().split('.').last}';
      } else {
        action = HistoryAction.updated;
        changeDescription = 'Activity details updated';
      }
      
      // Add to history
      final history = ActivityHistory(
        activityId: activity.id,
        action: action,
        previousState: oldActivity.toMap(),
        newState: activity.toMap(),
        changeDescription: changeDescription,
      );
      
      await _database.insertActivityHistory(history);
      print('History entry added: ${history.toString()}');
      
      // Refresh the activities list
      print('Activity updated successfully, refreshing list...');
      await fetchActivities();
      
      // Notify listeners
      notifyListeners();
    } catch (e) {
      print('Error updating activity: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      print('Deleting activity with id: $id');
      final activity = _activities.firstWhere((a) => a.id == id);
      
      await _database.deleteActivity(id);
      
      // Add to history
      final history = ActivityHistory(
        activityId: id,
        action: HistoryAction.deleted,
        previousState: activity.toMap(),
        changeDescription: 'Activity deleted',
      );
      await _database.insertActivityHistory(history);
      
      print('Activity deleted successfully, refreshing list...');
      await fetchActivities();
    } catch (e) {
      print('Error deleting activity: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreActivity(Activity activity) async {
    try {
      await _database.insertActivity(activity);
      _activities = [..._activities, activity];

      final history = ActivityHistory(
        activityId: activity.id,
        action: HistoryAction.created,
        newState: activity.toMap(),
        changeDescription: 'Activity restored',
      );
      await _database.insertActivityHistory(history);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<ActivityHistory>> getActivityHistory(String activityId) async {
    try {
      print('Fetching history for activity: $activityId');
      return await _database.getActivityHistoryById(activityId);
    } catch (e) {
      print('Error fetching activity history: $e');
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 