import 'package:flutter/material.dart';
import '../../home/models/activity.dart';

class RecentTransactions extends StatelessWidget {
  final List<Activity> transactions;

  const RecentTransactions({required this.transactions, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions
          .map((t) => ListTile(
                title: Text(t.title),
                subtitle: Text(t.category),
                trailing: Text(t.amount.toString()),
              ))
          .toList(),
    );
  }
}
