import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../shared/services/firebase_service.dart';
import 'package:logger/logger.dart';

class FamilyProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final _logger = Logger();
  List<Map<String, dynamic>> _familyGroups = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _subscription;

  FamilyProvider(this._firebaseService) {
    _init();
  }

  void _init() {
    final user = _firebaseService.currentUser;
    if (user != null && user.email != null) {
      _setupFamilyListener(user.email!);
    }
  }

  void _setupFamilyListener(String userEmail) {
    _subscription?.cancel();
    _subscription = _firebaseService.realtimeDatabase.getFamilyGroups(userEmail).listen(
      (event) {
        final data = event.snapshot.value;
        if (data is Map) {
          _familyGroups = data.entries.map<Map<String, dynamic>>((entry) {
            final group = Map<String, dynamic>.from(entry.value as Map);
            group['id'] = entry.key;
            return group;
          }).toList();
        } else {
          _familyGroups = [];
        }
        notifyListeners();
      },
      onError: (error) {
        _logger.e('Error listening to family groups', error: error);
        _error = 'Failed to load family groups';
        notifyListeners();
      },
    );
  }

  List<Map<String, dynamic>> get familyGroups => _familyGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createFamilyGroup({
    required String name,
    required List<String> memberEmails,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('Creating family group: $name');
      await _firebaseService.createFamilyGroup(
        name: name,
        memberEmails: memberEmails,
      );
      _logger.i('Family group created successfully');
    } catch (e) {
      _logger.e('Failed to create family group', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
} 