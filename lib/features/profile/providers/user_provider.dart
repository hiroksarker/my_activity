import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  final _logger = Logger();
  FirebaseAuth? _auth;
  FirebaseStorage? _storage;
  
  User? _user;
  String? _profileImageUrl;
  bool _isLoading = false;

  User? get user => _user;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  UserProvider() {
    try {
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;
      _init();
    } catch (e) {
      _logger.w('Firebase not initialized: $e');
    }
  }

  void _init() {
    if (_auth == null) return;
    
    _user = _auth!.currentUser;
    if (_user != null) {
      _loadProfileImage();
    }
    _auth!.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadProfileImage();
      } else {
        _profileImageUrl = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfileImage() async {
    if (_storage == null || _user == null) return;
    
    try {
      final ref = _storage!.ref().child('profile_images/${_user!.uid}');
      _profileImageUrl = await ref.getDownloadURL();
      notifyListeners();
    } catch (e) {
      _logger.w('Failed to load profile image: $e');
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (_storage == null || _user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final ref = _storage!.ref().child('profile_images/${_user!.uid}');
      await ref.putFile(imageFile);
      _profileImageUrl = await ref.getDownloadURL();
      
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
    if (_auth == null || _user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _user!.updateDisplayName(name);
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
    if (_auth == null) return;
    
    try {
      await _auth!.signOut();
      _user = null;
      _profileImageUrl = null;
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Failed to sign out: $e');
      rethrow;
    }
  }
} 