import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home/models/activity.dart';

class TransactionList extends StatelessWidget {
  final List<Activity> transactions;
  final Function(Activity) onTransactionTap;

  const TransactionList({
    required this.transactions,
    required this.onTransactionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a transaction',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction.transactionType == TransactionType.debit;
        final amount = transaction.amount?.abs() ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpense
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            title: Text(transaction.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.description != null) ...[
                  const SizedBox(height: 4),
                  Text(transaction.description!),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(transaction.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              '${isExpense ? '-' : '+'}${currencyFormat.format(amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => onTransactionTap(transaction),
          ),
        );
      },
    );
  }
} 