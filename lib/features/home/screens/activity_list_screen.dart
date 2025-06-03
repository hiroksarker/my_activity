import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';
import '../../activities/providers/activity_provider.dart';
import '../widgets/activity_form_dialog.dart';
import '../widgets/activity_card.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  ActivityType? _selectedType;
  ActivityStatus? _selectedStatus;
  ActivityPriority? _selectedPriority;
  String? _searchQuery;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Activities',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ActivitySearchDelegate(
                  context.read<ActivityProvider>(),
                ),
              );
            },
            tooltip: 'Search Activities',
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
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

          var activities = provider.activities;

          if (_selectedType != null) {
            activities = activities.where((a) => a.type == _selectedType).toList();
          }

          if (_selectedStatus != null) {
            activities = activities.where((a) => a.status == _selectedStatus).toList();
          }

          if (_selectedPriority != null) {
            activities = activities.where((a) => a.priority == _selectedPriority).toList();
          }

          if (_searchQuery != null && _searchQuery!.isNotEmpty) {
            final query = _searchQuery!.toLowerCase();
            activities = activities.where((activity) {
              return activity.title.toLowerCase().contains(query) ||
                  activity.description.toLowerCase().contains(query) ||
                  activity.category.toLowerCase().contains(query);
            }).toList();
          }

          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  if (_selectedType != null || _selectedStatus != null || _selectedPriority != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = null;
                          _selectedStatus = null;
                          _selectedPriority = null;
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActivityCard(
                  activity: activity,
                  onStatusChange: () => _showStatusDialog(context, activity),
                  onEdit: () => _showEditDialog(context, activity),
                  onDelete: () => _showDeleteDialog(context, activity),
                  onTap: () => _showActivityDetails(context, activity),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Activity'),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<ActivityStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...ActivityStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...ActivityPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedPriority = value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _selectedStatus = null;
                      _selectedPriority = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, Activity activity) {
    final statuses = ActivityStatus.values;
    final statusColors = {
      ActivityStatus.active: Colors.blue,
      ActivityStatus.completed: Colors.green,
      ActivityStatus.archived: Colors.grey,
    };
    final statusIcons = {
      ActivityStatus.active: Icons.play_circle,
      ActivityStatus.completed: Icons.check_circle,
      ActivityStatus.archived: Icons.archive,
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Change Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...statuses.map((status) {
            final isCurrent = status == activity.status;
            return ListTile(
              leading: Icon(
                statusIcons[status],
                color: statusColors[status],
              ),
              title: Text(
                status.toString().split('.').last,
                style: TextStyle(
                  color: statusColors[status],
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle, color: statusColors[status])
                  : null,
              onTap: () {
                context.read<ActivityProvider>().updateActivityStatus(
                      activity.id,
                      status,
                    );
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        activity: activity,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete "${activity.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ActivityProvider>().deleteActivity(activity.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      activity.categoryIcon,
                      size: 32,
                      color: activity.categoryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            activity.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: activity.categoryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(context, activity);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (activity.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(activity.description),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Status',
                        activity.status.toString().split('.').last,
                        _getStatusIcon(activity.status),
                        _getStatusColor(activity.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Priority',
                        activity.priority.toString().split('.').last,
                        _getPriorityIcon(activity.priority),
                        _getPriorityColor(activity.priority),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Created',
                        _formatDate(activity.createdAt),
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Updated',
                        _formatDate(activity.updatedAt),
                        Icons.update,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showStatusDialog(context, activity);
                  },
                  icon: const Icon(Icons.change_circle),
                  label: const Text('Change Status'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Icons.play_circle;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.archived:
        return Icons.archive;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Icons.arrow_downward;
      case ActivityPriority.regular:
        return Icons.remove;
      case ActivityPriority.high:
        return Icons.arrow_upward;
      case ActivityPriority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Colors.green;
      case ActivityPriority.regular:
        return Colors.blue;
      case ActivityPriority.high:
        return Colors.orange;
      case ActivityPriority.urgent:
        return Colors.red;
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ActivityFormDialog(),
    );
  }
}

class ActivitySearchDelegate extends SearchDelegate<String> {
  final ActivityProvider _provider;

  ActivitySearchDelegate(this._provider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a search term',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Activity>>(
      future: _provider.searchActivities(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
          );
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActivityCard(
                activity: activity,
                onStatusChange: () {
                  close(context, '');
                  _showStatusDialog(context, activity);
                },
                onEdit: () {
                  close(context, '');
                  _showEditDialog(context, activity);
                },
                onDelete: () {
                  close(context, '');
                  _showDeleteDialog(context, activity);
                },
                onTap: () {
                  close(context, '');
                  _showActivityDetails(context, activity);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, Activity activity) {
    final statuses = ActivityStatus.values;
    final statusColors = {
      ActivityStatus.active: Colors.blue,
      ActivityStatus.completed: Colors.green,
      ActivityStatus.archived: Colors.grey,
    };
    final statusIcons = {
      ActivityStatus.active: Icons.play_circle,
      ActivityStatus.completed: Icons.check_circle,
      ActivityStatus.archived: Icons.archive,
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Change Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...statuses.map((status) {
            final isCurrent = status == activity.status;
            return ListTile(
              leading: Icon(
                statusIcons[status],
                color: statusColors[status],
              ),
              title: Text(
                status.toString().split('.').last,
                style: TextStyle(
                  color: statusColors[status],
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle, color: statusColors[status])
                  : null,
              onTap: () {
                _provider.updateActivityStatus(
                  activity.id,
                  status,
                );
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        activity: activity,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete "${activity.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _provider.deleteActivity(activity.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      activity.categoryIcon,
                      size: 32,
                      color: activity.categoryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            activity.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: activity.categoryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(context, activity);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (activity.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(activity.description),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Status',
                        activity.status.toString().split('.').last,
                        _getStatusIcon(activity.status),
                        _getStatusColor(activity.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Priority',
                        activity.priority.toString().split('.').last,
                        _getPriorityIcon(activity.priority),
                        _getPriorityColor(activity.priority),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Created',
                        _formatDate(activity.createdAt),
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        'Updated',
                        _formatDate(activity.updatedAt),
                        Icons.update,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showStatusDialog(context, activity);
                  },
                  icon: const Icon(Icons.change_circle),
                  label: const Text('Change Status'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Icons.play_circle;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.archived:
        return Icons.archive;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.active:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Icons.arrow_downward;
      case ActivityPriority.regular:
        return Icons.remove;
      case ActivityPriority.high:
        return Icons.arrow_upward;
      case ActivityPriority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(ActivityPriority priority) {
    switch (priority) {
      case ActivityPriority.low:
        return Colors.green;
      case ActivityPriority.regular:
        return Colors.blue;
      case ActivityPriority.high:
        return Colors.orange;
      case ActivityPriority.urgent:
        return Colors.red;
    }
  }
}
