import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../home/providers/activity_provider.dart';
import '../../home/models/activity_history.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String? transactionId;

  const TransactionHistoryScreen({
    super.key,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: FutureBuilder<List<ActivityHistory>>(
        future: context.read<ActivityProvider>().getActivityHistory(transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final history = snapshot.data!;
          if (history.isEmpty) {
            return const Center(
              child: Text('No history found'),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entry.color.withOpacity(0.2),
                    child: Icon(
                      entry.icon,
                      color: entry.color,
                    ),
                  ),
                  title: Text(
                    entry.displayText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: entry.color,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMd().add_jm().format(entry.timestamp),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (entry.changeDescription != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.changeDescription!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 