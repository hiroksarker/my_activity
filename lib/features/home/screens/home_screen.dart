import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activities/providers/activity_provider.dart';
import '../../activities/models/activity.dart';
import '../../activities/models/activity_enums.dart';
import '../../finances/screens/modern_finance_screen.dart';
import 'activity_list_screen.dart';
import '../../activities/models/activity_history.dart';
import '../../budgets/pages/budgets_list_page.dart';
import '../../daily_explorer/screens/daily_dashboard_screen.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../documents/screens/documents_screen.dart';
import '../../../widgets/modern_background.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    const DailyDashboardScreen(), // New Daily Explorer as the main screen
    const ActivityListScreen(),
    const ModernFinanceScreen(),
    BudgetsListPage(),
    const CalendarPage(),
  ];

  Future<void> _updateActivityStatus(Activity activity, ActivityStatus newStatus) async {
    final updatedActivity = activity.copyWith(status: newStatus);
    await context.read<ActivityProvider>().updateActivity(updatedActivity);
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Modern Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'My Activity',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your personal companion',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.explore,
                  title: 'Daily Explorer',
                  subtitle: 'Travel companion & activities',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0);
                  },
                  isSelected: _selectedIndex == 0,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.task_alt,
                  title: 'Tasks & Activities',
                  subtitle: 'Manage your daily tasks',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 1);
                  },
                  isSelected: _selectedIndex == 1,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Finances',
                  subtitle: 'Track income & expenses',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 2);
                  },
                  isSelected: _selectedIndex == 2,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pie_chart,
                  title: 'Budgets & Trips',
                  subtitle: 'Plan your travel budget',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 3);
                  },
                  isSelected: _selectedIndex == 3,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Calendar',
                  subtitle: 'Schedule & events',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 4);
                  },
                  isSelected: _selectedIndex == 4,
                ),
                
                const Divider(height: 32),
                
                // Additional Features
                _buildDrawerItem(
                  context,
                  icon: Icons.folder_outlined,
                  title: 'Documents',
                  subtitle: 'Manage your files',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/documents');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  subtitle: 'View insights & reports',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/analytics');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                  child: const Text('About'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryBlue.withOpacity(0.2)
                : AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'My Activity',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.explore,
          color: AppTheme.primaryBlue,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'A comprehensive personal activity and travel companion app with features for task management, financial tracking, travel planning, and daily exploration.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Daily Explorer - Travel companion'),
        const Text('• Task & Activity Management'),
        const Text('• Financial Tracking'),
        const Text('• Budget & Trip Planning'),
        const Text('• Calendar Integration'),
        const Text('• Document Management'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // This allows more than 3 tabs
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Finances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
      floatingActionButton: _buildContextualFAB(context),
    );
  }

  // Navigation item for Explorer
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add buttons for other features
  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Context-specific action methods
  void _showExplorerActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explorer Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capture and explore your activities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.camera_alt,
                        label: 'Take Photo',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Open camera
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camera feature coming soon!')),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.location_on,
                        label: 'Add Location',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Add location
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location feature coming soon!')),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.note_add,
                        label: 'Quick Note',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Add quick note
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quick note feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    Navigator.pushNamed(context, '/form-demo').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  void _showAddExpenseDialog(BuildContext context) {
    Navigator.pushNamed(context, '/form-demo').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showAddBudgetDialog(BuildContext context) {
    Navigator.pushNamed(context, '/form-demo').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip/Budget added successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  void _showAddEventDialog(BuildContext context) {
    Navigator.pushNamed(context, '/form-demo').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event added successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildContextualFAB(BuildContext context) {
    switch (_selectedIndex) {
      case 0: // Explorer - Show camera/capture button
        return FloatingActionButton(
          onPressed: () => _showExplorerActions(context),
          backgroundColor: Colors.purple,
          child: const Icon(Icons.camera_alt),
          tooltip: 'Capture Activity',
        );
      case 1: // Tasks - Show add task button
        return FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: AppTheme.primaryBlue,
          child: const Icon(Icons.add_task),
          tooltip: 'Add Task',
        );
      case 2: // Finances - Show add expense button
        return FloatingActionButton(
          onPressed: () => _showAddExpenseDialog(context),
          backgroundColor: AppTheme.success,
          child: const Icon(Icons.attach_money),
          tooltip: 'Add Expense',
        );
      case 3: // Budgets - Show add trip/budget button
        return FloatingActionButton(
          onPressed: () => _showAddBudgetDialog(context),
          backgroundColor: AppTheme.accent,
          child: const Icon(Icons.flight_takeoff),
          tooltip: 'Plan Trip',
        );
      case 4: // Calendar - Show add event button
        return FloatingActionButton(
          onPressed: () => _showAddEventDialog(context),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.event),
          tooltip: 'Add Event',
        );
      default:
        return null;
    }
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an action to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Quick Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildQuickActionItem(
                        context,
                        icon: Icons.add_task,
                        label: 'Add Task',
                        color: AppTheme.primaryBlue,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 1);
                          // TODO: Show add task dialog
                        },
                      ),
                      _buildQuickActionItem(
                        context,
                        icon: Icons.attach_money,
                        label: 'Add Expense',
                        color: AppTheme.success,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 2);
                          // TODO: Show add expense dialog
                        },
                      ),
                      _buildQuickActionItem(
                        context,
                        icon: Icons.flight_takeoff,
                        label: 'Plan Trip',
                        color: AppTheme.accent,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 3);
                          // TODO: Show add trip dialog
                        },
                      ),
                      _buildQuickActionItem(
                        context,
                        icon: Icons.camera_alt,
                        label: 'Capture',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 0);
                          // TODO: Open camera for Daily Explorer
                        },
                      ),
                      _buildQuickActionItem(
                        context,
                        icon: Icons.event,
                        label: 'Add Event',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 4);
                          // TODO: Show add event dialog
                        },
                      ),
                      _buildQuickActionItem(
                        context,
                        icon: Icons.design_services,
                        label: 'Form Demo',
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/form-demo');
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
    ActivityStatus.archived: Colors.grey,
  };
  final statusIcons = {
    ActivityStatus.active: Icons.play_circle,
    ActivityStatus.completed: Icons.check_circle,
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
    if (context.mounted) {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      if (homeState != null) {
        await homeState._updateActivityStatus(task, selected);
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
                    title: Text(entry.action),
                    subtitle: Text(entry.description),
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