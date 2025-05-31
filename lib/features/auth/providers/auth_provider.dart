import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:developer'; // For log()
import 'package:logger/logger.dart';

class AuthProvider with ChangeNotifier {
  late final PocketBase _pb;
  final Logger _logger = Logger();
  RecordModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    final baseUrl = Platform.isAndroid
        ? 'http://10.0.2.2:8090'  // Android emulator
        : 'http://127.0.0.1:8090'; // iOS simulator and physical devices
    _pb = PocketBase(baseUrl);
    _user = _pb.authStore.model;
  }

  RecordModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('Attempting sign up for $email');
      await _pb.collection('users').create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'name': name,
        },
      );
      log('Sign up successful for $email');
      await signIn(email: email, password: password);
      return true;
    } catch (e) {
      _error = e.toString();
      log('Sign up error for $email: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('Attempting sign in for $email');
      await _pb.collection('users').authWithPassword(email, password);
      _user = _pb.authStore.model;
      log('Sign in successful for $email');
      return true;
    } catch (e) {
      _error = e.toString();
      log('Sign in error for $email: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _pb.authStore.clear();
    _user = null;
    notifyListeners();
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _pb.collection('users').requestPasswordReset(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request email verification
  Future<bool> requestVerification(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _pb.collection('users').requestVerification(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? avatar,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (avatar != null) body['avatar'] = avatar;

      final record = await _pb.collection('users').update(
        _user!.id,
        body: body,
      );
      _user = record;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload user avatar
  Future<String?> uploadAvatar(List<int> fileBytes, String fileName) async {
    if (_user == null) return null;

    try {
      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        fileBytes,
        filename: fileName,
      );

      final record = await _pb.collection('users').update(
        _user!.id,
        body: {},
        files: [multipartFile],
      );
      
      _user = record;
      return record.getStringValue('avatar');
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
} 