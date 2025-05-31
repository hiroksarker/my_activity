import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/services/firebase_service.dart';
import 'package:logger/logger.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final _logger = Logger();
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  AuthProvider(this._firebaseService) {
    _init();
  }

  void _init() {
    _firebaseService.auth.authStateChanges().listen((User? user) {
      _user = user;
      _isEmailVerified = user?.emailVerified ?? false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _isEmailVerified;
  Stream<User?> get authStateChanges => _firebaseService.auth.authStateChanges();

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
      final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (name != null && name.isNotEmpty) {
        await userCredential.user?.updateDisplayName(name);
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      // Sign out until email is verified
      await signOut();
      
      _logger.i('Sign up successful, verification email sent');
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
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in.',
        );
      }

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
      await _firebaseService.auth.signOut();
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
      await _firebaseService.resetPassword(email);
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Password reset failed', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _logger.i('Verification email resent');
      }
    } catch (e) {
      _logger.e('Failed to resend verification email', error: e);
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 