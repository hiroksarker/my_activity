import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<ActivityProvider>().loadActivities()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadActivities(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Upcoming
                Text('Upcoming', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _UpcomingList(activities: provider.getUpcomingActivities()),
                const SizedBox(height: 24),
                
                // Recent Activity
                Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _RecentActivityList(activities: provider.getRecentActivities()),
                const SizedBox(height: 24),
                
                // Progress
                Text('Progress', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ProgressBar(
                  label: 'Official Work',
                  value: provider.getProgressByCategory('Official Work'),
                ),
                ProgressBar(
                  label: 'Personal Work',
                  value: provider.getProgressByCategory('Personal Work'),
                ),
                ProgressBar(
                  label: 'Personal Growth',
                  value: provider.getProgressByCategory('Personal Growth'),
                ),
                ProgressBar(
                  label: 'Finance Tracking',
                  value: provider.getProgressByCategory('Finance Tracking'),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddActivityDialog(context),
                        icon: const Icon(Icons.add_task),
                        label: const Text('Add Task'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddActivityDialog(context, isExpense: true),
                        icon: const Icon(Icons.add_chart),
                        label: const Text('Add Expense'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddActivityDialog(BuildContext context, {bool isExpense = false}) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = isExpense ? 'Finance Tracking' : 'Official Work';
    double progress = 0.0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isExpense ? 'Add Expense' : 'Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Official Work',
                    'Personal Work',
                    'Personal Growth',
                    'Finance Tracking',
                  ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Progress: '),
                    Expanded(
                      child: Slider(
                        value: progress,
                        onChanged: (value) => setState(() => progress = value),
                        divisions: 10,
                        label: '${(progress * 100).toInt()}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final activity = Activity(
                    title: titleController.text,
                    category: selectedCategory,
                    date: DateTime.now(),
                    progress: progress,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  context.read<ActivityProvider>().addActivity(activity);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  final List<Activity> activities;

  const _UpcomingList({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No upcoming activities'),
      );
    }

    return Column(
      children: activities.map((activity) => _UpcomingItem(
        title: activity.title,
        time: DateFormat.jm().format(activity.date),
        category: activity.category,
      )).toList(),
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  final String title;
  final String time;
  final String category;

  const _UpcomingItem({
    required this.title,
    required this.time,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForCategory(category),
        color: Colors.blueGrey,
      ),
      title: Text(title),
      subtitle: Text(category),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      contentPadding: EdgeInsets.zero,
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Official Work':
        return Icons.work;
      case 'Personal Work':
        return Icons.person;
      case 'Personal Growth':
        return Icons.self_improvement;
      case 'Finance Tracking':
        return Icons.attach_money;
      default:
        return Icons.event;
    }
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<Activity> activities;

  const _RecentActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No recent activities'),
      );
    }

    return Column(
      children: activities.map((activity) => _RecentActivityItem(
        title: activity.title,
        time: _getTimeAgo(activity.date),
        category: activity.category,
      )).toList(),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _RecentActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String category;

  const _RecentActivityItem({
    required this.title,
    required this.time,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForCategory(category),
        color: Colors.blueGrey,
      ),
      title: Text(title),
      subtitle: Text(category),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      contentPadding: EdgeInsets.zero,
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Official Work':
        return Icons.work;
      case 'Personal Work':
        return Icons.person;
      case 'Personal Growth':
        return Icons.self_improvement;
      case 'Finance Tracking':
        return Icons.attach_money;
      default:
        return Icons.event;
    }
  }
}