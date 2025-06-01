import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../db/budgets_database.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];

  List<Trip> get trips => _trips;

  Future<void> loadTrips() async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('trips', orderBy: 'startDate DESC');
    _trips = maps.map((map) => Trip.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('trips', trip.toMap());
    await loadTrips();
  }

  Future<void> updateTrip(Trip trip) async {
    final db = await BudgetsDatabase.instance.database;
    await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
    await loadTrips();
  }

  Future<void> deleteTrip(int id) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
    await loadTrips();
  }

  Trip? getTripById(int id) {
    try {
      return _trips.firstWhere((trip) => trip.id == id);
    } catch (_) {
      return null;
    }
  }
}
