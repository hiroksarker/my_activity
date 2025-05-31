import 'package:flutter/material.dart';
import '../../home/models/activity.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final Activity transaction;
  const TransactionItem({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amount < 0;
    final amount = transaction.amount.abs();
    return Container(
      // ... your code for a single transaction item ...
    );
  }
}
