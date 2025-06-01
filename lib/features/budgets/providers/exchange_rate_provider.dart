import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../db/budgets_database.dart';

class ExchangeRateProvider with ChangeNotifier {
  List<ExchangeRate> _rates = [];

  List<ExchangeRate> get rates => _rates;

  Future<void> loadRates() async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('exchange_rates', orderBy: 'date DESC');
    _rates = maps.map((map) => ExchangeRate.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addRate(ExchangeRate rate) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('exchange_rates', rate.toMap());
    await loadRates();
  }

  Future<void> updateRate(ExchangeRate rate) async {
    final db = await BudgetsDatabase.instance.database;
    await db.update(
      'exchange_rates',
      rate.toMap(),
      where: 'id = ?',
      whereArgs: [rate.id],
    );
    await loadRates();
  }

  Future<void> deleteRate(int id) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('exchange_rates', where: 'id = ?', whereArgs: [id]);
    await loadRates();
  }
}
