import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;
import '../../activity/pages/home_page.dart';
import '../../tasks/pages/tasks_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../finances/pages/finance_page.dart';
import '../../profile/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    TasksPage(),
    CalendarPage(),
    FinancePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.task_outlined,
              color: _selectedIndex == 1 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.task,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: _selectedIndex == 2 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.attach_money_outlined,
              color: _selectedIndex == 3 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.attach_money,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Finances',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: _selectedIndex == 4 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 