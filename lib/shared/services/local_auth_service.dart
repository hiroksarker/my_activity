import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class LocalAuthService {
  final SharedPreferences _prefs;
  final Logger _logger = Logger();

  LocalAuthService(this._prefs);

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if user already exists
      if (_prefs.containsKey('user_$email')) {
        throw Exception('User already exists');
      }

      // Hash the password
      final hashedPassword = _hashPassword(password);

      // Store user data
      await _prefs.setString('user_$email', jsonEncode({
        'email': email,
        'password': hashedPassword,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      }));

      // Set current user
      await _prefs.setString('current_user', email);
      
      _logger.i('User signed up successfully: $email');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Sign up error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userData = _prefs.getString('user_$email');
      if (userData == null) {
        throw Exception('User not found');
      }

      final user = jsonDecode(userData) as Map<String, dynamic>;
      final hashedPassword = _hashPassword(password);

      if (user['password'] != hashedPassword) {
        throw Exception('Invalid password');
      }

      // Set current user
      await _prefs.setString('current_user', email);
      
      _logger.i('User signed in successfully: $email');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Sign in error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _prefs.remove('current_user');
      _logger.i('User signed out successfully');
    } catch (e, stackTrace) {
      _logger.e('Sign out error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  String? getCurrentUser() {
    return _prefs.getString('current_user');
  }

  Map<String, dynamic>? getUserData(String email) {
    final userData = _prefs.getString('user_$email');
    if (userData == null) return null;
    return jsonDecode(userData) as Map<String, dynamic>;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
} 