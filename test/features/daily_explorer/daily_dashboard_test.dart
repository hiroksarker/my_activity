import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_activity/features/daily_explorer/screens/daily_dashboard_screen.dart';
import 'package:my_activity/features/daily_explorer/providers/daily_explorer_provider.dart';
import 'package:my_activity/core/theme/app_theme.dart';

void main() {
  group('DailyDashboardScreen Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Create a test app with the required provider
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => DailyExplorerProvider(),
            child: const DailyDashboardScreen(),
          ),
        ),
      );

      // Verify that the screen renders
      expect(find.byType(DailyDashboardScreen), findsOneWidget);
      
      // Verify that key UI elements are present
      expect(find.text('Daily Explorer'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show empty state when no activities', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => DailyExplorerProvider(),
            child: const DailyDashboardScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Should show empty state when no activities
      expect(find.text('No Activities Today'), findsOneWidget);
    });

    testWidgets('should show quick action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => DailyExplorerProvider(),
            child: const DailyDashboardScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify quick action buttons are present
      expect(find.text('Capture'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
    });
  });
}