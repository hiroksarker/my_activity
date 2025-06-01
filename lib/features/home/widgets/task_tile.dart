import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';

class TaskTile extends StatelessWidget {
  final Activity task;
  const TaskTile(this.task, {super.key});

  Color getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.cancelled:
        return Colors.red;
      case ActivityStatus.archived:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Icons.radio_button_unchecked;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.cancelled:
        return Icons.cancel;
      case ActivityStatus.archived:
        return Icons.archive;
      default:
        return Icons.task;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getStatusColor(task.status).withOpacity(0.15),
          child: Icon(
            getStatusIcon(task.status),
            color: getStatusColor(task.status),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: getStatusColor(task.status),
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  task.description,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Created: ${task.createdAt.toLocal().toString().split(' ').first}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: getStatusColor(task.status).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task.status.toString().split('.').last,
            style: TextStyle(
              color: getStatusColor(task.status),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        onTap: () => showStatusDialog(context, task),
        onLongPress: () => showTaskHistoryDialog(context, task),
      ),
    );
  }
}

Future<void> showStatusDialog(BuildContext context, Activity task) async {
  final statuses = ActivityStatus.values;
  final statusColors = {
    ActivityStatus.active: Colors.blue,
    ActivityStatus.completed: Colors.green,
    ActivityStatus.cancelled: Colors.red,
    ActivityStatus.archived: Colors.grey,
  };
  final statusIcons = {
    ActivityStatus.active: Icons.radio_button_unchecked,
    ActivityStatus.completed: Icons.check_circle,
    ActivityStatus.cancelled: Icons.cancel,
    ActivityStatus.archived: Icons.archive,
  };

  final selected = await showModalBottomSheet<ActivityStatus>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Theme.of(context).cardColor,
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Status',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.map((status) {
            final isSelected = status == task.status;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context, status),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? statusColors[status]!.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcons[status],
                      color: statusColors[status],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        status.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: statusColors[status],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, color: statusColors[status], size: 22),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (selected != null && selected != task.status) {
    final updatedTask = task.copyWith(status: selected);
    await context.read<ActivityProvider>().updateActivity(updatedTask);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status changed to ${selected.toString().split('.').last}'),
        backgroundColor: statusColors[selected],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

Future<void> showTaskHistoryDialog(BuildContext context, Activity task) async {
  // Implementation of showTaskHistoryDialog
}
