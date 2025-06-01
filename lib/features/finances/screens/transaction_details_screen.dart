import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/edit_transaction_dialog.dart';
import '../screens/transaction_history_screen.dart';
import '../../../widgets/confirmation_dialog.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Activity transaction;

  const TransactionDetailsScreen({
    required this.transaction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = transaction.transactionType == TransactionType.debit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionHistoryScreen(
                    transactionId: transaction.id,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditTransactionDialog(
                  transaction: transaction,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(
                  title: 'Delete Transaction',
                  content: 'Are you sure you want to delete this transaction? This action cannot be undone.',
                  icon: Icons.delete_rounded,
                  iconColor: Colors.red,
                  onConfirm: () {
                    context.read<ActivityProvider>().deleteActivity(transaction.id);
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    backgroundColor: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: transaction.categoryIcon,
                    label: 'Category',
                    value: transaction.category,
                    color: transaction.categoryColor,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat.yMMMd().add_jm().format(transaction.timestamp),
                  ),
                  if (transaction.description?.isNotEmpty ?? false) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.description,
                      label: 'Description',
                      value: transaction.description!,
                    ),
                  ],
                  if (transaction.isRecurring) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      icon: Icons.repeat,
                      label: 'Recurrence',
                      value: '${transaction.recurrenceType}',
                    ),
                    if (transaction.nextOccurrence != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.event,
                        label: 'Next Occurrence',
                        value: DateFormat.yMMMd().format(transaction.nextOccurrence!),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: color ?? theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 