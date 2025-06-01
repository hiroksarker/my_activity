import 'package:flutter/material.dart';
import '../models/trip_info.dart';
import '../db/budgets_database.dart';

class TripInfoProvider with ChangeNotifier {
  List<TripInfo> _infos = [];

  List<TripInfo> get infos => _infos;

  Future<void> loadTripInfo(int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('trip_info', where: 'tripId = ?', whereArgs: [tripId]);
    _infos = maps.map((map) => TripInfo.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTripInfo(TripInfo info) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('trip_info', info.toMap());
    await loadTripInfo(info.tripId);
  }

  Future<void> updateTripInfo(TripInfo info) async {
    final db = await BudgetsDatabase.instance.database;
    await db.update(
      'trip_info',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [info.id],
    );
    await loadTripInfo(info.tripId);
  }

  Future<void> deleteTripInfo(int id, int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('trip_info', where: 'id = ?', whereArgs: [id]);
    await loadTripInfo(tripId);
  }
}
