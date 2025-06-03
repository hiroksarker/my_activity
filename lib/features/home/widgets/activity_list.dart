import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../activities/providers/activity_provider.dart';
import '../models/activity.dart';
import 'edit_activity_dialog.dart';
import 'activity_history_dialog.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchActivities(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final activities = provider.activities;
        if (activities.isEmpty) {
          return const Center(
            child: Text(
              'No activities yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityListItem(
              key: ValueKey(activity.id),
              activity: activity,
              onDelete: () => provider.deleteActivity(activity.id),
              onEdit: () {
                showDialog(
                  context: context,
                  builder: (context) => EditActivityDialog(activity: activity),
                );
              },
              onViewHistory: () {
                showDialog(
                  context: context,
                  builder: (context) => ActivityHistoryDialog(activity: activity),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final Activity activity;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewHistory;

  const _ActivityListItem({
    required Key key,
    required this.activity,
    required this.onDelete,
    required this.onEdit,
    required this.onViewHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = activity.type == ActivityType.expense;

    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onEdit,
          onLongPress: onViewHistory,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isExpense
                          ? (activity.transactionType == TransactionType.debit
                              ? theme.colorScheme.error.withOpacity(0.1)
                              : theme.colorScheme.primary.withOpacity(0.1))
                          : theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        isExpense
                            ? (activity.transactionType == TransactionType.debit
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline)
                            : Icons.task_alt,
                        color: isExpense
                            ? (activity.transactionType == TransactionType.debit
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (!isExpense) ...[
                            const SizedBox(height: 4),
                            _buildStatusChip(theme),
                          ],
                        ],
                      ),
                    ),
                    if (isExpense)
                      Text(
                        '${activity.transactionType == TransactionType.debit ? '-' : '+'}\$${activity.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: activity.transactionType == TransactionType.debit
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(activity.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.category,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.category.toUpperCase(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color chipColor;
    IconData statusIcon;

    switch (activity.status) {
      case TaskStatus.pending:
        chipColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        chipColor = Colors.blue;
        statusIcon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        chipColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case TaskStatus.cancelled:
        chipColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            activity.status.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 