import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RealtimeDatabaseService {
  static final RealtimeDatabaseService _instance = RealtimeDatabaseService._internal();
  factory RealtimeDatabaseService() => _instance;
  
  final _database = FirebaseDatabase.instance;
  final _logger = Logger();
  bool _isLocalMode = false;

  RealtimeDatabaseService._internal() {
    _logger.i('Initializing RealtimeDatabaseService...');
    _setupLocalMode();
  }

  void _setupLocalMode() {
    if (_isLocalMode) {
      // For local development, use the local emulator
      _database.useDatabaseEmulator('10.0.2.2', 9000);
      _logger.i('Using local database emulator at 10.0.2.2:9000');
    } else {
      // For production, use the actual database URL
      _database.setPersistenceEnabled(true);
      _logger.i('Using production database at ${_database.databaseURL}');
    }
  }

  // Toggle between local and production database
  void toggleLocalMode(bool useLocal) {
    _isLocalMode = useLocal;
    _setupLocalMode();
  }

  // User methods
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      await _database.ref('users/$userId').set({
        'email': email,
        'name': name,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      _logger.i('User profile created in Realtime Database: $userId');
    } catch (e) {
      _logger.e('Failed to create user profile', error: e);
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': ServerValue.timestamp,
      };
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _database.ref('users/$userId').update(updates);
      _logger.i('User profile updated in Realtime Database: $userId');
    } catch (e) {
      _logger.e('Failed to update user profile', error: e);
      rethrow;
    }
  }

  // Activity methods
  Future<void> createActivity({
    required String userId,
    required String title,
    required String description,
    required DateTime date,
    required String category,
    double? amount,
    required String status,
  }) async {
    try {
      final activityRef = _database.ref('activities').push();
      await activityRef.set({
        'userId': userId,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'category': category,
        'amount': amount,
        'status': status,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      _logger.i('Activity created in Realtime Database: ${activityRef.key}');
    } catch (e) {
      _logger.e('Failed to create activity', error: e);
      rethrow;
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
      final updates = <String, dynamic>{
        'updatedAt': ServerValue.timestamp,
      };
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (date != null) updates['date'] = date.toIso8601String();
      if (category != null) updates['category'] = category;
      if (amount != null) updates['amount'] = amount;
      if (status != null) updates['status'] = status;

      await _database.ref('activities/$activityId').update(updates);
      _logger.i('Activity updated in Realtime Database: $activityId');
    } catch (e) {
      _logger.e('Failed to update activity', error: e);
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _database.ref('activities/$activityId').remove();
      _logger.i('Activity deleted from Realtime Database: $activityId');
    } catch (e) {
      _logger.e('Failed to delete activity', error: e);
      rethrow;
    }
  }

  Stream<DatabaseEvent> getActivities(String userId) {
    try {
      return _database
          .ref('activities')
          .orderByChild('userId')
          .equalTo(userId)
          .onValue;
    } catch (e) {
      _logger.e('Failed to get activities stream', error: e);
      rethrow;
    }
  }

  // Family group methods
  Future<void> createFamilyGroup({
    required String userId,
    required String name,
    required List<String> memberEmails,
  }) async {
    try {
      final familyRef = _database.ref('family_groups').push();
      await familyRef.set({
        'name': name,
        'createdBy': userId,
        'createdAt': ServerValue.timestamp,
        'members': [userId],
        'memberEmails': memberEmails,
        'status': 'pending',
      });

      // Create invitations
      for (final email in memberEmails) {
        await _database.ref('family_invitations').push().set({
          'familyGroupId': familyRef.key,
          'email': email,
          'sentAt': ServerValue.timestamp,
          'status': 'pending',
        });
      }
      _logger.i('Family group created in Realtime Database: ${familyRef.key}');
    } catch (e) {
      _logger.e('Failed to create family group', error: e);
      rethrow;
    }
  }

  Stream<DatabaseEvent> getFamilyGroups(String userEmail) {
    try {
      return _database
          .ref('family_groups')
          .orderByChild('memberEmails')
          .equalTo(userEmail)
          .onValue;
    } catch (e) {
      _logger.e('Failed to get family groups stream', error: e);
      rethrow;
    }
  }
} 