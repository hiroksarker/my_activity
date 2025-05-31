import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/providers/activity_provider.dart';
import '../features/home/models/activity.dart';
import '../features/finances/widgets/finances_header.dart';
import '../features/finances/widgets/balance_card.dart';
import '../features/finances/widgets/recent_transactions.dart';
import 'package:intl/intl.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  String _selectedPeriod = 'This Month';
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<ActivityProvider>().fetchActivities()
    );
  }

  List<Activity> _getFilteredActivities(List<Activity> activities) {
    final now = DateTime.now();
    final startDate = switch (_selectedPeriod) {
      'This Week' => now.subtract(Duration(days: now.weekday - 1)),
      'This Month' => DateTime(now.year, now.month, 1),
      'This Year' => DateTime(now.year, 1, 1),
      'All Time' => DateTime(2000),
      _ => DateTime(now.year, now.month, 1),
    };

    return activities
        .where((activity) => 
            activity.category == 'Finance Tracking' && 
            activity.date.isAfter(startDate))
        .toList();
  }

  Map<String, double> _calculateTotals(List<Activity> activities) {
    double income = 0;
    double expenses = 0;

    for (var activity in activities) {
      if (activity.amount > 0) {
        income += activity.amount;
      } else {
        expenses += activity.amount.abs();
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<ActivityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchActivities(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final filteredActivities = _getFilteredActivities(provider.activities);
            final totals = _calculateTotals(filteredActivities);

            return RefreshIndicator(
              onRefresh: () => provider.fetchActivities(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FinancesHeader(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (value) => setState(() => _selectedPeriod = value),
                    ),
                    const SizedBox(height: 16),
                    BalanceCard(
                      balance: totals['balance']!,
                      income: totals['income']!,
                      expenses: totals['expenses']!,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentTransactions(transactions: filteredActivities),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTransactionDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isExpense = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(isExpense ? 'Expense' : 'Income'),
                  value: isExpense,
                  onChanged: (value) => setState(() => isExpense = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                final finalAmount = isExpense ? -amount : amount;
                
                final activity = Activity(
                  title: titleController.text,
                  description: descriptionController.text,
                  amount: finalAmount,
                  category: 'Finance Tracking',
                  status: 'completed',
                  date: DateTime.now(),
                );

                context.read<ActivityProvider>().addActivity(activity);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
} 