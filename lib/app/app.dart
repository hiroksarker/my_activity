import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/providers/activity_provider.dart';
import '../tasks/view/tasks_page.dart';
import '../finances/view/finances_page.dart';
import '../calendar/view/calendar_page.dart';
import '../profile/view/profile_page.dart';
import '../home/view/home_page.dart';
import 'core/initialization/app_initializer.dart';
import 'app/app.dart'; // <-- Use the correct MyApp

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    TasksPage(),
    CalendarPage(),
    FinancesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Activity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          surface: const Color(0xFFF5F7FA),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'SF Pro Text',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        ),
      ),
      home: Scaffold(
        body: PageView(
          children: [
            HomePage(),
            TasksPage(),
            CalendarPage(),
            FinancesPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF3B82F6).withOpacity(0.1),
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: _selectedIndex == 0 ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                ),
                selectedIcon: const Icon(
                  Icons.home,
                  color: Color(0xFF3B82F6),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.task_outlined,
                  color: _selectedIndex == 1 ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                ),
                selectedIcon: const Icon(
                  Icons.task,
                  color: Color(0xFF3B82F6),
                ),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: _selectedIndex == 2 ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                ),
                selectedIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3B82F6),
                ),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.attach_money_outlined,
                  color: _selectedIndex == 3 ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                ),
                selectedIcon: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF3B82F6),
                ),
                label: 'Finances',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: _selectedIndex == 4 ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                ),
                selectedIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF3B82F6),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}