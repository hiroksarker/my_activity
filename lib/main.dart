import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'shared/services/firebase_service.dart';
import 'features/auth/providers/auth_provider.dart' as app_auth;
import 'features/home/providers/activity_provider.dart';
import 'features/family/providers/family_provider.dart' as app_family;
import 'features/home/pages/home_page.dart';
import 'features/tasks/view/tasks_page.dart';
import 'features/calendar/view/calendar_page.dart';
import 'features/finances/view/finances_page.dart';
import 'features/profile/view/profile_page.dart';
import 'features/auth/pages/login_page.dart';
import 'shared/theme/app_theme.dart';
import 'shared/utils/logger.dart';
import 'features/home/services/activity_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  LoggerService.initialize();
  final logger = LoggerService.logger;
  
  bool useFirebase = false;
  
  try {
    // Check if we're in development mode
    const isDevelopment = bool.fromEnvironment('FLUTTER_DEVELOPMENT', defaultValue: true);
    
    if (!isDevelopment) {
      logger.i('Initializing Firebase in production mode...');
      
      // Load environment variables
      const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
      const firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
      const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
      const firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
      const firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
      const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
      const firebaseMeasurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

      // Check if all required Firebase config values are present
      if (firebaseApiKey.isNotEmpty &&
          firebaseAuthDomain.isNotEmpty &&
          firebaseProjectId.isNotEmpty &&
          firebaseStorageBucket.isNotEmpty &&
          firebaseMessagingSenderId.isNotEmpty &&
          firebaseAppId.isNotEmpty) {
        
        // Clear any existing Firebase instances
        for (var app in Firebase.apps) {
          await app.delete();
        }
        
        // Initialize Firebase with a new instance
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: firebaseApiKey,
            authDomain: firebaseAuthDomain,
            projectId: firebaseProjectId,
            storageBucket: firebaseStorageBucket,
            messagingSenderId: firebaseMessagingSenderId,
            appId: firebaseAppId,
            measurementId: firebaseMeasurementId,
            databaseURL: 'https://$firebaseProjectId.firebaseio.com',
          ),
        );

        // Initialize Firebase App Check
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );

        useFirebase = true;
        logger.i('Firebase initialized successfully');
      } else {
        logger.w('Firebase configuration incomplete, running in local mode');
      }
    } else {
      logger.i('Running in development mode with local storage');
    }
  } catch (e, stackTrace) {
    logger.e('Failed to initialize Firebase', error: e, stackTrace: stackTrace);
    logger.i('Continuing in local mode');
  }

  final database = ActivityDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivityProvider>(
          create: (_) => ActivityProvider(database),
        ),
        if (useFirebase) ...[
          Provider<FirebaseService>(
            create: (_) => FirebaseService(),
          ),
          ChangeNotifierProvider<app_auth.AuthProvider>(
            create: (context) => app_auth.AuthProvider(
              Provider.of<FirebaseService>(context, listen: false),
            ),
          ),
          ChangeNotifierProvider<app_family.FamilyProvider>(
            create: (context) => app_family.FamilyProvider(
              Provider.of<FirebaseService>(context, listen: false),
            ),
          ),
        ],
      ],
      child: MaterialApp(
        title: 'My Activity',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: useFirebase 
          ? Consumer<app_auth.AuthProvider>(
              builder: (context, authProvider, _) {
                return StreamBuilder(
                  stream: authProvider.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasData) {
                      return const MainNavigation();
                    }
                    
                    return const LoginPage();
                  },
                );
              },
            )
          : const MainNavigation(),
      ),
    ),
  );
}

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Theme.of(context).primaryColor.withOpacity(0.1),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? Theme.of(context).primaryColor : const Color(0xFF6B7280),
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.task_outlined,
              color: _selectedIndex == 1 ? Theme.of(context).primaryColor : const Color(0xFF6B7280),
            ),
            selectedIcon: Icon(
              Icons.task,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: _selectedIndex == 2 ? Theme.of(context).primaryColor : const Color(0xFF6B7280),
            ),
            selectedIcon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.attach_money_outlined,
              color: _selectedIndex == 3 ? Theme.of(context).primaryColor : const Color(0xFF6B7280),
            ),
            selectedIcon: Icon(
              Icons.attach_money,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Finances',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: _selectedIndex == 4 ? Theme.of(context).primaryColor : const Color(0xFF6B7280),
            ),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
