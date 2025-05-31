import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'realtime_database_service.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _database = RealtimeDatabaseService();
  final _logger = Logger();
  final _firebaseDatabase = FirebaseDatabase.instance;
  bool _isLocalMode = false;

  FirebaseService._internal() {
    _logger.i('Initializing FirebaseService...');
  }

  // Auth methods
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _logger.i('Attempting to sign up user: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _logger.i('User created successfully, creating profile...');
        await _database.createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          name: name,
        );
        _logger.i('User profile created successfully');
      }

      return userCredential;
    } catch (e) {
      _logger.e('Failed to sign up user', error: e);
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting to sign in user: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _logger.e('Failed to sign in user', error: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _logger.i('Signing out user...');
      await _auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Failed to sign out user', error: e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Failed to send password reset email', error: e);
      rethrow;
    }
  }

  // User profile methods
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      _logger.i('Updating user profile for: ${user.uid}');
      await _database.updateUserProfile(
        userId: user.uid,
        name: name,
        photoUrl: photoUrl,
      );
      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Failed to update user profile', error: e);
      rethrow;
    }
  }

  // Activity methods
  Future<void> createActivity({
    required String title,
    required String description,
    required DateTime date,
    required String category,
    double? amount,
    required String status,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      _logger.i('Creating new activity: $title');
      await _database.createActivity(
        userId: user.uid,
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
      _logger.i('Updating activity: $activityId');
      await _database.updateActivity(
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
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      _logger.i('Deleting activity: $activityId');
      await _database.deleteActivity(activityId);
      _logger.i('Activity deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete activity', error: e);
      rethrow;
    }
  }

  // Family group methods
  Future<void> createFamilyGroup({
    required String name,
    required List<String> memberEmails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      _logger.i('Creating new family group: $name');
      await _database.createFamilyGroup(
        userId: user.uid,
        name: name,
        memberEmails: memberEmails,
      );
      _logger.i('Family group created successfully');
    } catch (e) {
      _logger.e('Failed to create family group', error: e);
      rethrow;
    }
  }

  // Getters
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  RealtimeDatabaseService get realtimeDatabase => _database;
  FirebaseStorage get storage => _storage;

  // Toggle local mode for development
  void toggleLocalMode(bool enabled) {
    _isLocalMode = enabled;
    if (enabled) {
      _firebaseDatabase.useDatabaseEmulator('localhost', 9000);
      _auth.useAuthEmulator('localhost', 9099);
      _database.toggleLocalMode(true);
    } else {
      _database.toggleLocalMode(false);
    }
  }

  // Expose auth instance
  FirebaseAuth get auth => _auth;
  
  // Expose database services with distinct names
  FirebaseDatabase get firebaseDatabase => _firebaseDatabase;
} 