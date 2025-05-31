import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance: \$${balance.toStringAsFixed(2)}'),
            Text('Income: \$${income.toStringAsFixed(2)}'),
            Text('Expenses: \$${expenses.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
