import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:io' show Platform;
import '../models/activity.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class ActivityProvider with ChangeNotifier {
  List<Activity> _activities = [];
  late final PocketBase _pb;
  bool _isLoading = false;
  String? _error;

  ActivityProvider() {
    // Initialize PocketBase with platform-aware host
    final baseUrl = Platform.isAndroid 
        ? 'http://10.0.2.2:8090'  // Android emulator
        : 'http://127.0.0.1:8090'; // iOS simulator and physical devices
    _pb = PocketBase(baseUrl);
  }

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all activities
  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _pb.collection('activities').getList(
        page: 1,
        perPage: 100,
        sort: '-date',
      );

      _activities = result.items.map((item) => Activity.fromJson(item.toJson())).toList();
    } catch (e, stack) {
      _logger.e('Error in fetchActivities: $e\n$stack');
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new activity
  Future<void> addActivity(Activity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final record = await _pb.collection('activities').create(
        body: activity.toJson(),
      );

      final newActivity = Activity.fromJson(record.toJson());
      _activities.add(newActivity);
      _activities.sort((a, b) => b.date.compareTo(a.date));
    } catch (e, stack) {
      _logger.e('Error in addActivity: $e\n$stack');
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update activity
  Future<void> updateActivity(Activity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final record = await _pb.collection('activities').update(
        activity.id,
        body: activity.toJson(),
      );

      final updatedActivity = Activity.fromJson(record.toJson());
      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
        _activities.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e, stack) {
      _logger.e('Error in updateActivity: $e\n$stack');
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete activity
  Future<void> deleteActivity(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _pb.collection('activities').delete(id);
      _activities.removeWhere((activity) => activity.id == id);
    } catch (e, stack) {
      _logger.e('Error in deleteActivity: $e\n$stack');
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subscribe to real-time updates
  void subscribeToChanges() {
    _pb.collection('activities').subscribe('*', (e) {
      if (e.action == 'create') {
        final newActivity = Activity.fromJson(e.record!.toJson());
        _activities.add(newActivity);
      } else if (e.action == 'update') {
        final updatedActivity = Activity.fromJson(e.record!.toJson());
        final index = _activities.indexWhere((a) => a.id == updatedActivity.id);
        if (index != -1) {
          _activities[index] = updatedActivity;
        }
      } else if (e.action == 'delete') {
        _activities.removeWhere((a) => a.id == e.record!.id);
      }
      _activities.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromChanges() {
    _pb.collection('activities').unsubscribe();
  }

  // Get upcoming activities
  List<Activity> getUpcomingActivities() {
    final now = DateTime.now();
    return _activities
        .where((activity) => activity.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get recent activities
  List<Activity> getRecentActivities() {
    final now = DateTime.now();
    return _activities
        .where((activity) => activity.date.isBefore(now))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getProgressByCategory(String category) {
    final categoryActivities = _activities.where((a) => a.category == category);
    if (categoryActivities.isEmpty) return 0.0;
    
    final completedActivities = categoryActivities.where((a) => a.status == 'completed').length;
    return completedActivities / categoryActivities.length;
  }

  @override
  void dispose() {
    unsubscribeFromChanges();
    super.dispose();
  }
} 