import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';
import '../models/travel_activity.dart';
import '../models/travel_alert.dart';
import '../models/travel_memory.dart';

class PocketBaseService {
  static const String _baseUrl = kDebugMode 
      ? 'http://localhost:8090' 
      : 'https://your-production-url.com';
  
  late final PocketBase _pb;
  
  // Collection names
  static const String activitiesCollection = 'travel_activities';
  static const String alertsCollection = 'travel_alerts';
  static const String memoriesCollection = 'travel_memories';
  static const String usersCollection = 'users';

  PocketBaseService() {
    _pb = PocketBase(_baseUrl);
  }

  PocketBase get client => _pb;

  // Authentication methods
  Future<bool> get isAuthenticated async {
    return _pb.authStore.isValid;
  }

  String? get currentUserId => _pb.authStore.model?.id;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _pb.collection(usersCollection).create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      });
      
      // Auto sign in after successful registration
      await signIn(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _pb.collection(usersCollection).authWithPassword(email, password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
  }

  // Travel Activities CRUD
  Future<List<TravelActivity>> getActivities({
    DateTime? startDate,
    DateTime? endDate,
    ActivityStatus? status,
  }) async {
    try {
      final filters = <String>[];
      
      if (currentUserId != null) {
        filters.add('userId = "${currentUserId!}"');
      }
      
      if (startDate != null) {
        filters.add('startTime >= "${startDate.toIso8601String()}"');
      }
      
      if (endDate != null) {
        filters.add('endTime <= "${endDate.toIso8601String()}"');
      }
      
      if (status != null) {
        filters.add('status = "${status.name}"');
      }

      final records = await _pb.collection(activitiesCollection).getList(
        filter: filters.join(' && '),
        sort: 'startTime',
      );

      return records.items
          .map((record) => TravelActivity.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  Future<TravelActivity> createActivity(TravelActivity activity) async {
    try {
      final data = activity.toJson();
      data['userId'] = currentUserId;
      data.remove('id'); // Let PocketBase generate the ID
      
      final record = await _pb.collection(activitiesCollection).create(body: data);
      return TravelActivity.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  Future<TravelActivity> updateActivity(TravelActivity activity) async {
    try {
      final data = activity.toJson();
      data['updatedAt'] = DateTime.now().toIso8601String();
      
      final record = await _pb.collection(activitiesCollection).update(
        activity.id,
        body: data,
      );
      return TravelActivity.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _pb.collection(activitiesCollection).delete(activityId);
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Travel Alerts CRUD
  Future<List<TravelAlert>> getAlerts({
    bool activeOnly = true,
  }) async {
    try {
      final filters = <String>[];
      
      if (currentUserId != null) {
        filters.add('userId = "${currentUserId!}"');
      }
      
      if (activeOnly) {
        filters.add('isDismissed = false');
        filters.add('(expiresAt = "" || expiresAt > "${DateTime.now().toIso8601String()}")');
      }

      final records = await _pb.collection(alertsCollection).getList(
        filter: filters.join(' && '),
        sort: '-priority,-timestamp',
      );

      return records.items
          .map((record) => TravelAlert.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get alerts: $e');
    }
  }

  Future<TravelAlert> createAlert(TravelAlert alert) async {
    try {
      final data = alert.toJson();
      data['userId'] = currentUserId;
      data.remove('id');
      
      final record = await _pb.collection(alertsCollection).create(body: data);
      return TravelAlert.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to create alert: $e');
    }
  }

  Future<TravelAlert> updateAlert(TravelAlert alert) async {
    try {
      final record = await _pb.collection(alertsCollection).update(
        alert.id,
        body: alert.toJson(),
      );
      return TravelAlert.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to update alert: $e');
    }
  }

  Future<void> dismissAlert(String alertId) async {
    try {
      await _pb.collection(alertsCollection).update(alertId, body: {
        'isDismissed': true,
      });
    } catch (e) {
      throw Exception('Failed to dismiss alert: $e');
    }
  }

  // Travel Memories CRUD
  Future<List<TravelMemory>> getMemories({
    String? activityId,
    DateTime? date,
  }) async {
    try {
      final filters = <String>[];
      
      if (currentUserId != null) {
        filters.add('userId = "${currentUserId!}"');
      }
      
      if (activityId != null) {
        filters.add('activityId = "$activityId"');
      }
      
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        filters.add('timestamp >= "${startOfDay.toIso8601String()}"');
        filters.add('timestamp < "${endOfDay.toIso8601String()}"');
      }

      final records = await _pb.collection(memoriesCollection).getList(
        filter: filters.join(' && '),
        sort: '-timestamp',
      );

      return records.items
          .map((record) => TravelMemory.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get memories: $e');
    }
  }

  Future<TravelMemory> createMemory(TravelMemory memory) async {
    try {
      final data = memory.toJson();
      data['userId'] = currentUserId;
      data.remove('id');
      
      final record = await _pb.collection(memoriesCollection).create(body: data);
      return TravelMemory.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to create memory: $e');
    }
  }

  Future<void> deleteMemory(String memoryId) async {
    try {
      await _pb.collection(memoriesCollection).delete(memoryId);
    } catch (e) {
      throw Exception('Failed to delete memory: $e');
    }
  }

  // File upload for photos and attachments
  Future<String> uploadFile(String filePath, String collection, String recordId) async {
    try {
      // TODO: Implement file upload when needed
      // This will require proper multipart file handling
      throw UnimplementedError('File upload not yet implemented');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Real-time subscriptions
  void subscribeToActivities(Function(TravelActivity) onUpdate) {
    _pb.collection(activitiesCollection).subscribe('*', (e) {
      if (e.record != null) {
        final activity = TravelActivity.fromJson(e.record!.toJson());
        onUpdate(activity);
      }
    });
  }

  void subscribeToAlerts(Function(TravelAlert) onAlert) {
    _pb.collection(alertsCollection).subscribe('*', (e) {
      if (e.record != null && e.action == 'create') {
        final alert = TravelAlert.fromJson(e.record!.toJson());
        onAlert(alert);
      }
    });
  }

  void unsubscribe() {
    _pb.collection(activitiesCollection).unsubscribe();
    _pb.collection(alertsCollection).unsubscribe();
  }
}