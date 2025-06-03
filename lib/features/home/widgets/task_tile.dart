import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';
import '../../activities/providers/activity_provider.dart';
import 'activity_form_dialog.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;

  const ActivityTile({
    super.key,
    required this.activity,
  });

  Color getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.expense:
        return Colors.red;
      case ActivityType.income:
        return Colors.green;
    }
  }

  IconData getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.expense:
        return Icons.arrow_downward;
      case ActivityType.income:
        return Icons.arrow_upward;
    }
  }

  Color getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.archived:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Icons.play_circle;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.archived:
        return Icons.archive;
    }
  }

  Color getPriorityColor(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.default_:
        return Colors.grey;
      case ActivityPriority.important:
        return Colors.orange;
    }
  }

  IconData getPriorityIcon(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.default_:
        return Icons.flag_outlined;
      case ActivityPriority.important:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getActivityTypeColor(activity.type),
          child: Icon(
            getActivityTypeIcon(activity.type),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                activity.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: activity.status == ActivityStatus.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            if (activity.priority == ActivityPriority.important)
              Icon(
                getPriorityIcon(activity.priority),
                color: getPriorityColor(activity.priority),
                size: 20,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            if (activity.amount != null)
              Text(
                '${activity.transactionType == TransactionType.expense ? '-' : '+'}\$${activity.amount!.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: activity.transactionType == TransactionType.expense
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Row(
              children: [
                Icon(
                  getStatusIcon(activity.status),
                  size: 16,
                  color: getStatusColor(activity.status),
                ),
                const SizedBox(width: 4),
                Text(
                  activity.status.toString().split('.').last,
                  style: TextStyle(
                    color: getStatusColor(activity.status),
                  ),
                ),
                if (activity.isRecurring) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.repeat, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    activity.recurrenceType.toString().split('.').last,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            Text(
              'Category: ${activity.category}',
              style: theme.textTheme.bodySmall,
            ),
            if (activity.subcategory != null)
              Text(
                'Subcategory: ${activity.subcategory}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                activity.status == ActivityStatus.completed
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: activity.status == ActivityStatus.completed
                    ? Colors.green
                    : Colors.grey,
              ),
              onPressed: () {
                context.read<ActivityProvider>().updateActivityStatus(
                      activity.id,
                      activity.status == ActivityStatus.completed
                          ? ActivityStatus.active
                          : ActivityStatus.completed,
                    );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ActivityFormDialog(
                    activity: activity,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Activity'),
                    content: const Text(
                      'Are you sure you want to delete this activity?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ActivityProvider>().deleteActivity(activity.id);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

