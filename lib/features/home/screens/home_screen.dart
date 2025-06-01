import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../../finances/screens/finance_screen.dart';
import 'activity_list_screen.dart';
import '../models/activity_history.dart';
import '../../budgets/pages/budgets_list_page.dart';
import '../../../widgets/green_pills_wallpaper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ActivityListScreen(),
    const FinanceScreen(),
    BudgetsListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GreenPillsWallpaper(
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'My Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Finances',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Budgets',
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Activity task;
  const TaskTile(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Text(task.status.toString().split('.').last),
      onTap: () => showStatusDialog(context, task),
      onLongPress: () => showTaskHistoryDialog(context, task),
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
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Change Task Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...statuses.map((status) {
          final isCurrent = status == task.status;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? statusColors[status]!.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
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
              onTap: () => Navigator.pop(context, status),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    ),
  );

  if (selected != null && selected != task.status) {
    final updatedTask = task.copyWith(status: selected);
    await context.read<ActivityProvider>().updateActivity(updatedTask);
    // Optionally show a snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status changed to ${selected.toString().split('.').last}'),
        backgroundColor: statusColors[selected],
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

Future<void> showTaskHistoryDialog(BuildContext context, Activity task) async {
  final provider = context.read<ActivityProvider>();
  final history = await provider.getActivityHistory(task.id);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('History for "${task.title}"'),
      content: SizedBox(
        width: double.maxFinite,
        child: history.isEmpty
            ? const Text('No history yet.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    leading: Icon(Icons.history, color: Colors.blueGrey),
                    title: Text(entry.changeType),
                    subtitle: Text(entry.changeDescription ?? ''),
                    trailing: Text(
                      entry.timestamp.toLocal().toString().split('.').first,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
} 