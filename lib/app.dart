import 'features/finances/screens/budgets_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Activity',
      theme: ThemeData(
        // ... existing theme configuration ...
      ),
      home: const HomeScreen(),
      routes: {
        '/': (context) => const HomeScreen(),
        '/budgets': (context) => const BudgetsScreen(),
        // ... existing routes ...
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.of(context).pushNamed('/budgets');
            },
            tooltip: 'Budgets',
          ),
          // ... existing actions ...
        ],
      ),
      // ... rest of the existing code ...
    );
  }
} 