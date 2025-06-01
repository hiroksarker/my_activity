import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class UserProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  String? _name;
  String? _email;

  UserProvider() {
    _loadUserData();
  }

  String? get name => _name;
  String? get email => _email;

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString('current_user_name');
      _email = prefs.getString('current_user');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error loading user data', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> updateUserData({String? name, String? email}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString('current_user_name', name);
        _name = name;
      }
      if (email != null) {
        await prefs.setString('current_user', email);
        _email = email;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error updating user data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_name');
      await prefs.remove('current_user');
      _name = null;
      _email = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error clearing user data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 