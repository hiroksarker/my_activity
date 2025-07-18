import 'package:flutter/material.dart';
import '../models/document.dart';

class DocumentProvider extends ChangeNotifier {
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock method for loading documents
  Future<void> loadAllDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock documents for demonstration
      _documents = [
        Document(
          id: 1,
          tripId: 1,
          type: 'PDF',
          filePath: '/documents/travel_insurance.pdf',
          description: 'Travel Insurance.pdf',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          fileSize: (2.3 * 1024 * 1024).round(), // 2.3 MB in bytes
          mimeType: 'application/pdf',
        ),
        Document(
          id: 2,
          tripId: 1,
          type: 'Image',
          filePath: '/documents/passport_copy.jpg',
          description: 'Passport Copy.jpg',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          fileSize: (1.8 * 1024 * 1024).round(), // 1.8 MB in bytes
          mimeType: 'image/jpeg',
        ),
      ];
    } catch (e) {
      _error = 'Failed to load documents: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock method for adding documents
  Future<void> addDocument(Document document) async {
    try {
      _documents.add(document);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add document: $e';
      notifyListeners();
    }
  }

  // Mock method for deleting documents
  Future<void> deleteDocument(int id, int tripId) async {
    try {
      _documents.removeWhere((doc) => doc.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete document: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 