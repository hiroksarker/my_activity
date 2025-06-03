import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/financial_transaction.dart' as models;
import '../models/transaction_history.dart';
import '../models/transaction_enums.dart';

class TransactionProvider extends ChangeNotifier {
  final _logger = Logger();
  final Database _database;
  final _uuid = const Uuid();
  List<models.FinancialTransaction> _transactions = [];
  List<TransactionHistory> _history = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  TransactionProvider(this._database) {
    _init();
  }

  bool get hasInitialized => _hasInitialized;
  List<models.FinancialTransaction> get transactions => _transactions;
  List<TransactionHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Financial getters
  List<models.FinancialTransaction> get expenses => _transactions.where((t) => t.type == TransactionType.expense).toList();
  List<models.FinancialTransaction> get income => _transactions.where((t) => t.type == TransactionType.income).toList();

  void _init() {
    _loadTransactions();
    _loadHistory();
    _hasInitialized = true;
  }

  Future<void> _loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final List<Map<String, dynamic>> transactions = await _database.query(
        'transactions',
        orderBy: 'createdAt DESC',
      );

      _transactions = transactions.map((map) => models.FinancialTransaction.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _logger.e('Error loading transactions', error: e);
      _error = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHistory() async {
    try {
      final List<Map<String, dynamic>> history = await _database.query(
        'transaction_history',
        orderBy: 'timestamp DESC',
      );

      _history = history.map((map) => TransactionHistory.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error loading transaction history', error: e);
    }
  }

  Future<void> createTransaction({
    required String title,
    String? description,
    required double amount,
    required TransactionType type,
    required String category,
    String? subcategory,
    bool isRecurring = false,
    String? recurrenceType,
    String? categoryIcon,
    String? categoryColor,
  }) async {
    try {
      final transaction = models.FinancialTransaction(
        id: _uuid.v4(),
        title: title,
        description: description,
        amount: amount,
        type: type,
        category: category,
        subcategory: subcategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isRecurring: isRecurring,
        recurrenceType: recurrenceType,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
      );

      await _database.insert('transactions', transaction.toMap());
      await _addToHistory(transaction, 'created');
      await _loadTransactions();
    } catch (e) {
      _logger.e('Error creating transaction', error: e);
      rethrow;
    }
  }

  Future<void> updateTransaction(models.FinancialTransaction transaction) async {
    try {
      await _database.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      await _addToHistory(transaction, 'updated');
      await _loadTransactions();
    } catch (e) {
      _logger.e('Error updating transaction', error: e);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == id);
      await _database.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      await _addToHistory(transaction, 'deleted');
      await _loadTransactions();
    } catch (e) {
      _logger.e('Error deleting transaction', error: e);
      rethrow;
    }
  }

  Future<void> _addToHistory(models.FinancialTransaction transaction, String action) async {
    try {
      final history = TransactionHistory(
        id: _uuid.v4(),
        transactionId: transaction.id,
        action: action,
        description: 'Transaction ${action.toLowerCase()}',
        timestamp: DateTime.now(),
      );

      await _database.insert('transaction_history', history.toMap());
      await _loadHistory();
    } catch (e) {
      _logger.e('Error adding to transaction history', error: e);
    }
  }

  Future<List<models.FinancialTransaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final List<Map<String, dynamic>> transactions = await _database.query(
        'transactions',
        where: 'createdAt BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'createdAt DESC',
      );

      return transactions.map((map) => models.FinancialTransaction.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error getting transactions by date range', error: e);
      rethrow;
    }
  }

  Future<List<models.FinancialTransaction>> getTransactionsByCategory(String category) async {
    try {
      final List<Map<String, dynamic>> transactions = await _database.query(
        'transactions',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );

      return transactions.map((map) => models.FinancialTransaction.fromMap(map)).toList();
    } catch (e) {
      _logger.e('Error getting transactions by category', error: e);
      rethrow;
    }
  }

  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final transactions = await _database.query(
      'transactions',
      where: 'isRecurring = 1 AND nextOccurrence IS NOT NULL AND nextOccurrence <= ?',
      whereArgs: [now.toIso8601String()],
    );

    for (final transaction in transactions) {
      final nextOccurrence = _calculateNextOccurrence(
        DateTime.parse(transaction['nextOccurrence'] as String),
        transaction['recurrenceType'] as String,
      );

      if (nextOccurrence != null) {
        final newTransaction = models.FinancialTransaction.fromMap(transaction).copyWith(
          id: _uuid.v4(),
          createdAt: now,
          updatedAt: now,
          nextOccurrence: nextOccurrence,
        );

        await _database.insert('transactions', newTransaction.toMap());
        await _addToHistory(newTransaction, 'recurred');
      }
    }

    await _loadTransactions();
  }

  DateTime? _calculateNextOccurrence(DateTime current, String recurrenceType) {
    switch (recurrenceType.toLowerCase()) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return null;
    }
  }

  // Financial calculation methods
  Future<double> getNetIncome(DateTime start, DateTime end) async {
    try {
      final transactions = await getTransactionsByDateRange(start, end);
      double total = 0;
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          total += transaction.amount;
        } else {
          total -= transaction.amount;
        }
      }
      return total;
    } catch (e) {
      _logger.e('Error calculating net income', error: e);
      rethrow;
    }
  }

  Future<Map<String, double>> getIncomeBySource(DateTime start, DateTime end) async {
    try {
      final transactions = await getTransactionsByDateRange(start, end);
      final Map<String, double> incomeBySource = {};
      
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          incomeBySource[transaction.category] = (incomeBySource[transaction.category] ?? 0) + transaction.amount;
        }
      }
      
      return incomeBySource;
    } catch (e) {
      _logger.e('Error calculating income by source', error: e);
      rethrow;
    }
  }

  Future<Map<String, double>> getExpensesByCategory(DateTime start, DateTime end) async {
    try {
      final transactions = await getTransactionsByDateRange(start, end);
      final Map<String, double> expensesByCategory = {};
      
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          expensesByCategory[transaction.category] = (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
        }
      }
      
      return expensesByCategory;
    } catch (e) {
      _logger.e('Error calculating expenses by category', error: e);
      rethrow;
    }
  }
} 