import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FamilyProvider extends ChangeNotifier {
  final _logger = Logger();
  List<Map<String, dynamic>> _familyGroups = [];
  bool _isLoading = false;
  String? _error;

  FamilyProvider() {
    _init();
  }

  void _init() {
    // Initialize with mock data for now
    _familyGroups = [
      {
        'id': '1',
        'name': 'My Family',
        'memberEmails': ['user@example.com'],
        'createdAt': DateTime.now().toIso8601String(),
      }
    ];
    notifyListeners();
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
      
      // Mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      final newGroup = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'memberEmails': memberEmails,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      _familyGroups.add(newGroup);
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
    super.dispose();
  }
} 