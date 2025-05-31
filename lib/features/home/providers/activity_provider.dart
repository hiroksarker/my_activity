import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../services/activity_database.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityDatabase _database = ActivityDatabase.instance;
  List<Activity> _activities = [];
  bool _isLoading = false;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activities = await _database.readAll();
    } catch (e) {
      debugPrint('Error loading activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      await _database.create(activity);
      await loadActivities();
    } catch (e) {
      debugPrint('Error adding activity: $e');
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      await _database.update(activity);
      await loadActivities();
    } catch (e) {
      debugPrint('Error updating activity: $e');
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _database.delete(id);
      await loadActivities();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
    }
  }

  double getProgressByCategory(String category) {
    final categoryActivities = _activities.where((a) => a.category == category);
    if (categoryActivities.isEmpty) return 0.0;
    
    final totalProgress = categoryActivities.fold<double>(
      0.0,
      (sum, activity) => sum + activity.progress,
    );
    return totalProgress / categoryActivities.length;
  }

  List<Activity> getRecentActivities() {
    return _activities.take(5).toList();
  }

  List<Activity> getUpcomingActivities() {
    final now = DateTime.now();
    return _activities
        .where((activity) => activity.date.isAfter(now))
        .take(3)
        .toList();
  }
} 