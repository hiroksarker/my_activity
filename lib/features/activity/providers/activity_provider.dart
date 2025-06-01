import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/activity_database.dart';
import 'package:logger/logger.dart';

class Activity {
  final int? id;
  final String title;
  final String? description;
  final DateTime date;
  final String type;
  final double? amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      amount: map['amount'] as double?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ActivityProvider extends ChangeNotifier {
  final ActivityDatabase _database;
  final Logger _logger = Logger();
  List<Activity> _activities = [];
  bool _isLoading = false;

  ActivityProvider(this._database);

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadActivities() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query('activities');

      _activities = List.generate(maps.length, (i) {
        return Activity.fromMap(maps[i]);
      });

      _logger.i('Loaded ${_activities.length} activities');
    } catch (e, stackTrace) {
      _logger.e('Error loading activities', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final db = await _database.database;
      final id = await db.insert('activities', activity.toMap());
      
      _activities.add(Activity(
        id: id,
        title: activity.title,
        description: activity.description,
        date: activity.date,
        type: activity.type,
        amount: activity.amount,
        createdAt: activity.createdAt,
        updatedAt: activity.updatedAt,
      ));

      _logger.i('Added new activity: ${activity.title}');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error adding activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      final db = await _database.database;
      await db.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );

      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        _logger.i('Updated activity: ${activity.title}');
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.e('Error updating activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      final db = await _database.database;
      await db.delete(
        'activities',
        where: 'id = ?',
        whereArgs: [id],
      );

      _activities.removeWhere((activity) => activity.id == id);
      _logger.i('Deleted activity with id: $id');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error deleting activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 