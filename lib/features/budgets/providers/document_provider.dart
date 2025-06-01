import 'package:flutter/material.dart';
import '../models/document.dart';
import '../db/budgets_database.dart';

class DocumentProvider with ChangeNotifier {
  List<Document> _documents = [];

  List<Document> get documents => _documents;

  Future<void> loadDocuments(int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('documents', where: 'tripId = ?', whereArgs: [tripId]);
    _documents = maps.map((map) => Document.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addDocument(Document doc) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('documents', doc.toMap());
    await loadDocuments(doc.tripId);
  }

  Future<void> updateDocument(Document doc) async {
    final db = await BudgetsDatabase.instance.database;
    await db.update(
      'documents',
      doc.toMap(),
      where: 'id = ?',
      whereArgs: [doc.id],
    );
    await loadDocuments(doc.tripId);
  }

  Future<void> deleteDocument(int id, int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
    await loadDocuments(tripId);
  }
}
