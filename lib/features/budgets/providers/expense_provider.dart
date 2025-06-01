import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../db/budgets_database.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses(int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    final maps = await db.query('expenses', where: 'tripId = ?', whereArgs: [tripId], orderBy: 'date DESC');
    _expenses = maps.map((map) => Expense.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    final db = await BudgetsDatabase.instance.database;
    await db.insert('expenses', expense.toMap());
    await loadExpenses(expense.tripId);
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await BudgetsDatabase.instance.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    await loadExpenses(expense.tripId);
  }

  Future<void> deleteExpense(int id, int tripId) async {
    final db = await BudgetsDatabase.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await loadExpenses(tripId);
  }

  Expense? getExpenseById(int id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
