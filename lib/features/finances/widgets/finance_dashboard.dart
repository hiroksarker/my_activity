import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';
import 'transaction_item.dart';
import 'travel_budget_dialog.dart';
import 'add_transaction_dialog.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  double _travelBudget = 1000.0; // This should come from user settings

  void _showTravelBudgetDialog() {
    showDialog<double>(
      context: context,
      builder: (context) => TravelBudgetDialog(currentBudget: _travelBudget),
    ).then((budget) {
      if (budget != null) {
        setState(() {
          _travelBudget = budget;
        });
        // TODO: Save budget to user settings
      }
    });
  }

  void _showEditTransactionDialog(BuildContext context, FinancialTransaction transaction) {
    showDialog<FinancialTransaction>(
      context: context,
      builder: (context) => AddTransactionDialog(
        transaction: transaction,
      ),
    ).then((updatedTransaction) {
      if (updatedTransaction != null) {
        context.read<TransactionProvider>().updateTransaction(updatedTransaction);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    // Filter and sort transactions
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Calculate totals
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;

    // Calculate travel expenses
    final travelExpenses = transactions
        .where((t) =>
            t.category == 'travel' &&
            t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Financial Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _showTravelBudgetDialog,
                      tooltip: 'Set Travel Budget',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Balance',
                        balance,
                        balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        totalIncome,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Expenses',
                        totalExpenses,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Travel Budget',
                        _travelBudget,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Travel Expenses',
                        travelExpenses,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final transaction = expenses[index];
            return TransactionItem(
              transaction: transaction,
              onTap: () => _showEditTransactionDialog(context, transaction),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 