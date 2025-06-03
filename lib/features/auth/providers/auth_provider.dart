import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final _logger = Logger();
  final _prefs = SharedPreferences.getInstance();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await _prefs;
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _user = json.decode(userData);
      notifyListeners();
    }
  }

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Signing up user: $email');
      final prefs = await _prefs;
      
      // Check if user already exists
      final existingUser = prefs.getString('user_$email');
      if (existingUser != null) {
        throw Exception('Email already registered');
      }

      // Create new user
      final userData = {
        'email': email,
        'password': _hashPassword(password),
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save user data
      await prefs.setString('user_$email', json.encode(userData));
      
      _logger.i('Sign up successful');
    } catch (e) {
      _logger.e('Sign up failed', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Signing in user: $email');
      final prefs = await _prefs;
      
      // Get user data
      final userData = prefs.getString('user_$email');
      if (userData == null) {
        throw Exception('User not found');
      }

      final user = json.decode(userData);
      if (user['password'] != _hashPassword(password)) {
        throw Exception('Invalid password');
      }

      // Store current user
      _user = user;
      await prefs.setString('user_data', json.encode(user));
      
      _logger.i('User signed in successfully');
    } catch (e) {
      _logger.e('Sign in failed', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Signing out user');
      final prefs = await _prefs;
      await prefs.remove('user_data');
      _user = null;
      
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Resetting password for: $email');
      final prefs = await _prefs;
      
      // Check if user exists
      final userData = prefs.getString('user_$email');
      if (userData == null) {
        throw Exception('User not found');
      }

      // Generate new password
      final newPassword = DateTime.now().millisecondsSinceEpoch.toString();
      final user = json.decode(userData);
      user['password'] = _hashPassword(newPassword);
      
      // Save updated user data
      await prefs.setString('user_$email', json.encode(user));
      
      // In a real app, you would send this password via email
      _logger.i('Password reset successful. New password: $newPassword');
    } catch (e) {
      _logger.e('Password reset failed', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 