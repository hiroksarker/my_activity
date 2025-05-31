import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/activity_provider.dart';

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Finances Coming Soon!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your income, expenses, and budget',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}