import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_enums.dart';

class TransactionItem extends StatelessWidget {
  final FinancialTransaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: transaction.categoryColorData,
                child: Icon(
                  transaction.categoryIconData,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.category} • ${DateFormat.yMMMd().format(transaction.createdAt)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${transaction.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
