import 'package:flutter/material.dart';
import '../models/itinerary_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ItineraryProvider with ChangeNotifier {
  List<ItineraryItem> _items = [];
  Database? _database;

  List<ItineraryItem> get items => _items;

  Future<void> initialize() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'itinerary.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE itinerary_items(
            id INTEGER PRIMARY KEY,
            tripId INTEGER NOT NULL,
            activity TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            notes TEXT NOT NULL,
            sortOrder INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> loadItinerary(int tripId) async {
    if (_database == null) await initialize();
    
    final List<Map<String, dynamic>> maps = await _database!.query(
      'itinerary_items',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'activity, date, time',
    );

    _items = maps.map((map) => ItineraryItem.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addItineraryItem(ItineraryItem item) async {
    if (_database == null) await initialize();

    try {
      await _database!.insert(
        'itinerary_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Reload items to ensure we have the latest data
      await loadItinerary(item.tripId);
    } catch (e) {
      print('Error adding itinerary item: $e');
      rethrow;
    }
  }

  Future<void> updateItineraryItem(ItineraryItem item) async {
    if (_database == null) await initialize();

    try {
      await _database!.update(
        'itinerary_items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      // Reload items to ensure we have the latest data
      await loadItinerary(item.tripId);
    } catch (e) {
      print('Error updating itinerary item: $e');
      rethrow;
    }
  }

  Future<void> deleteItineraryItem(int id, int tripId) async {
    if (_database == null) await initialize();

    try {
      await _database!.delete(
        'itinerary_items',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Reload items to ensure we have the latest data
      await loadItinerary(tripId);
    } catch (e) {
      print('Error deleting itinerary item: $e');
      rethrow;
    }
  }
}
