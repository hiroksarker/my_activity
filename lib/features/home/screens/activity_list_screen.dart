import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_tile.dart';

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<ActivityProvider>().activities
        .where((a) => a.type == ActivityType.task)
        .toList();

    final today = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;

    final todayTasks = tasks.where((t) => isToday(t.createdAt) && t.status == ActivityStatus.active).toList();
    final activeTasks = tasks.where((t) => t.status == ActivityStatus.active && !todayTasks.contains(t)).toList();
    final completedTasks = tasks.where((t) => t.status == ActivityStatus.completed).toList();
    final cancelledTasks = tasks.where((t) => t.status == ActivityStatus.cancelled).toList();
    final archivedTasks = tasks.where((t) => t.status == ActivityStatus.archived).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: ListView(
        children: [
          if (todayTasks.isNotEmpty) ...[
            const ListTile(title: Text('Today')),
            ...todayTasks.map((task) => TaskTile(task)),
          ],
          if (activeTasks.isNotEmpty) ...[
            const ListTile(title: Text('Active')),
            ...activeTasks.map((task) => TaskTile(task)),
          ],
          if (completedTasks.isNotEmpty) ...[
            const ListTile(title: Text('Completed')),
            ...completedTasks.map((task) => TaskTile(task)),
          ],
          if (cancelledTasks.isNotEmpty) ...[
            const ListTile(title: Text('Cancelled')),
            ...cancelledTasks.map((task) => TaskTile(task)),
          ],
          if (archivedTasks.isNotEmpty) ...[
            const ListTile(title: Text('Archived')),
            ...archivedTasks.map((task) => TaskTile(task)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTaskDialog(),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
