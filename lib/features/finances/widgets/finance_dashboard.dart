import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/models/activity.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/widgets/activity_form_dialog.dart';
import 'transaction_item.dart';
import 'travel_budget_dialog.dart';

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

  void _showEditTransactionDialog(BuildContext context, Activity activity) {
    showDialog<Activity>(
      context: context,
      builder: (context) => ActivityFormDialog(
        activity: activity,
      ),
    ).then((updatedActivity) {
      if (updatedActivity != null) {
        context.read<ActivityProvider>().updateActivity(updatedActivity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activityProvider = context.watch<ActivityProvider>();
    final activities = activityProvider.activities;

    // Filter and sort activities
    final expenses = activities
        .where((a) => a.type == ActivityType.expense)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Calculate totals
    final totalIncome = expenses
        .where((a) => a.transactionType == TransactionType.credit)
        .fold<double>(0, (sum, a) => sum + a.amount);
    final totalExpenses = expenses
        .where((a) => a.transactionType == TransactionType.debit)
        .fold<double>(0, (sum, a) => sum + a.amount);
    final balance = totalIncome - totalExpenses;

    // Calculate travel expenses
    final travelExpenses = expenses
        .where((a) =>
            a.category == 'travel' &&
            a.transactionType == TransactionType.debit)
        .fold<double>(0, (sum, a) => sum + a.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  amount: totalIncome,
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Expenses',
                  amount: totalExpenses,
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Balance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Travel Budget Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Travel Budget',
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showTravelBudgetDialog,
                        tooltip: 'Edit Travel Budget',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: travelExpenses / _travelBudget,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      travelExpenses > _travelBudget ? Colors.red : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${travelExpenses.toStringAsFixed(2)} / \$${_travelBudget.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent Transactions
          Text(
            'Recent Transactions',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (expenses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No transactions yet.\nTap + to add your first transaction!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = expenses[index];
                return TransactionItem(
                  activity: activity,
                  onTap: () => _showEditTransactionDialog(context, activity),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 