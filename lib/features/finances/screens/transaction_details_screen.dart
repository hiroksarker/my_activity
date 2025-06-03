import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';
import '../widgets/edit_transaction_dialog.dart';
import '../screens/transaction_history_screen.dart';
import '../../../widgets/confirmation_dialog.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final FinancialTransaction transaction;

  const TransactionDetailsScreen({
    required this.transaction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = transaction.type == TransactionType.expense;
    final amount = transaction.amount;

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
                  onConfirm: () async {
                    await context.read<TransactionProvider>().deleteTransaction(transaction.id);
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                        Expanded(
                          child: Text(
                            transaction.title,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          currencyFormat.format(amount),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        transaction.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(transaction.category),
                          avatar: Icon(
                            transaction.categoryIconData,
                            color: transaction.categoryColorData,
                          ),
                        ),
                        if (transaction.subcategory != null)
                          Chip(label: Text(transaction.subcategory!)),
                        Chip(
                          label: Text(transaction.type.toString().split('.').last),
                          backgroundColor: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        if (transaction.isRecurring)
                          Chip(
                            label: Text(transaction.recurrenceType ?? 'Recurring'),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      context,
                      'Created',
                      DateFormat.yMMMd().add_jm().format(transaction.createdAt),
                    ),
                    _buildDetailRow(
                      context,
                      'Last Updated',
                      DateFormat.yMMMd().add_jm().format(transaction.updatedAt),
                    ),
                    if (transaction.isRecurring && transaction.nextOccurrence != null)
                      _buildDetailRow(
                        context,
                        'Next Occurrence',
                        DateFormat.yMMMd().format(transaction.nextOccurrence!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
} 