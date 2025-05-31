import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../models/activity_history.dart';

class ActivityHistoryDialog extends StatelessWidget {
  final Activity activity;

  const ActivityHistoryDialog({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxHeight = size.height * 0.8;
    final maxWidth = size.width * 0.9;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: FutureBuilder<List<ActivityHistory>>(
                  future: context.read<ActivityProvider>().getActivityHistory(activity.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading history...'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading history: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Force rebuild to retry
                                  (context as Element).markNeedsBuild();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final history = snapshot.data ?? [];
                    if (history.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No history available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: _getActionIcon(entry.action),
                            title: Text(
                              entry.changeDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, y • h:mm a').format(entry.timestamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getActionIcon(HistoryAction action) {
    IconData iconData;
    Color iconColor;

    switch (action) {
      case HistoryAction.created:
        iconData = Icons.add_circle_outline;
        iconColor = Colors.green;
        break;
      case HistoryAction.updated:
        iconData = Icons.edit_outlined;
        iconColor = Colors.blue;
        break;
      case HistoryAction.deleted:
        iconData = Icons.delete_outline;
        iconColor = Colors.red;
        break;
      case HistoryAction.statusChanged:
        iconData = Icons.change_circle_outlined;
        iconColor = Colors.orange;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }
} 