import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  final _logger = Logger();
  final _prefs = SharedPreferences.getInstance();
  Map<String, dynamic>? _user;
  String? _profileImagePath;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  String? get profileImagePath => _profileImagePath;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await _prefs;
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _user = json.decode(userData);
      _profileImagePath = prefs.getString('profile_image_path');
      notifyListeners();
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await _prefs;
    _profileImagePath = prefs.getString('profile_image_path');
    notifyListeners();
  }

  Future<void> updateProfileImage(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get app's local directory
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_images');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'profile_$timestamp.jpg';
      final targetPath = '${profileDir.path}/$filename';

      // Copy image to app's local storage
      await imageFile.copy(targetPath);

      // Save path to preferences
      final prefs = await _prefs;
      await prefs.setString('profile_image_path', targetPath);
      
      _profileImagePath = targetPath;
      _logger.i('Profile image updated successfully');
    } catch (e) {
      _logger.e('Failed to update profile image: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await _prefs;
      final userData = prefs.getString('user_data');
      if (userData == null) throw Exception('No user logged in');

      final user = json.decode(userData);
      user['name'] = name;
      
      await prefs.setString('user_data', json.encode(user));
      _user = user;
      
      _logger.i('Display name updated successfully');
    } catch (e) {
      _logger.e('Failed to update display name: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await _prefs;
      await prefs.remove('user_data');
      await prefs.remove('profile_image_path');
      _user = null;
      _profileImagePath = null;
      _logger.i('User signed out successfully');
      notifyListeners();
    } catch (e) {
      _logger.e('Failed to sign out: $e');
      rethrow;
    }
  }
} 