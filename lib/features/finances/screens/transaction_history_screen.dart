import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_history.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String transactionId;

  const TransactionHistoryScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final history = provider.history
              .where((h) => h.transactionId == transactionId)
              .toList();

          if (history.isEmpty) {
            return const Center(
              child: Text('No history available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(entry.action),
                    child: Icon(
                      _getActionIcon(entry.action),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(entry.description),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(entry.timestamp),
                  ),
                  trailing: Text(
                    entry.action.toUpperCase(),
                    style: TextStyle(
                      color: _getActionColor(entry.action),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'deleted':
        return Colors.red;
      case 'recurred':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      case 'recurred':
        return Icons.repeat;
      default:
        return Icons.history;
    }
  }
} 