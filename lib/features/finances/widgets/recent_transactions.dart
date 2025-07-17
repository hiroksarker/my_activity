import 'package:flutter/material.dart';
import '../models/financial_transaction.dart';

class RecentTransactions extends StatelessWidget {
  final List<FinancialTransaction> transactions;

  const RecentTransactions({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions
          .map((t) => ListTile(
                title: Text(t.title),
                subtitle: Text(t.category),
                trailing: Text('\$${t.amount.toStringAsFixed(2)}'),
              ))
          .toList(),
    );
  }
}
