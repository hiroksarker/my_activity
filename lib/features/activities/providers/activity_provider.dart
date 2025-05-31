import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../shared/services/firebase_service.dart';
import 'package:logger/logger.dart';

class ActivityProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final _logger = Logger();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _subscription;
  bool _hasInitialized = false;

  ActivityProvider(this._firebaseService) {
    _init();
  }

  bool get hasInitialized => _hasInitialized;

  void _init() {
    final user = _firebaseService.currentUser;
    if (user != null) {
      _setupActivityListener(user.uid);
      _hasInitialized = true;
    }
  }

  void _setupActivityListener(String userId) {
    _subscription?.cancel();
    _subscription = _firebaseService.realtimeDatabase.getActivities(userId).listen(
      (event) {
        final data = event.snapshot.value;
        if (data is Map) {
          _activities = data.entries.map<Map<String, dynamic>>((entry) {
            final activity = Map<String, dynamic>.from(entry.value as Map);
            activity['id'] = entry.key;
            return activity;
          }).toList();
          _activities.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        } else {
          _activities = [];
        }
        notifyListeners();
      },
      onError: (error) {
        _logger.e('Error listening to activities', error: error);
        _error = 'Failed to load activities';
        notifyListeners();
      },
    );
  }

  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createActivity({
    required String title,
    required String description,
    required DateTime date,
    required String category,
    double? amount,
    required String status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Creating activity: $title');
      await _firebaseService.createActivity(
        title: title,
        description: description,
        date: date,
        category: category,
        amount: amount,
        status: status,
      );
      _logger.i('Activity created successfully');
    } catch (e) {
      _logger.e('Failed to create activity', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActivity({
    required String activityId,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    double? amount,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Updating activity: $activityId');
      await _firebaseService.updateActivity(
        activityId: activityId,
        title: title,
        description: description,
        date: date,
        category: category,
        amount: amount,
        status: status,
      );
      _logger.i('Activity updated successfully');
    } catch (e) {
      _logger.e('Failed to update activity', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Deleting activity: $activityId');
      await _firebaseService.deleteActivity(activityId);
      _logger.i('Activity deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete activity', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> fetchActivities() async {
    // Just re-initialize the subscription
    final user = _firebaseService.currentUser;
    if (user != null) {
      _setupActivityListener(user.uid);
    }
  }

  Future<void> addActivity(Map<String, dynamic> activity) async {
    await _firebaseService.createActivity(
      title: activity['title'],
      description: activity['description'],
      date: DateTime.parse(activity['date']),
      category: activity['category'],
      amount: activity['amount'],
      status: activity['status'],
    );
  }
} 