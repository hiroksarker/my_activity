import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_activity/main.dart' as app;
import 'package:my_activity/core/security/security_config.dart';
import 'package:my_activity/core/security/device_security.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('My Activity iOS Integration Tests', () {
    testWidgets('App launches and shows home screen with iOS UI', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches with iOS UI
      expect(find.byType(CupertinoApp), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      
      // Verify home screen elements
      expect(find.text('My Activity'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.home), findsOneWidget);
    });

    testWidgets('Activity List and iOS Gestures', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify activity list
      expect(find.byType(ListView), findsOneWidget);
      
      // Test iOS swipe to delete
      final activityItem = find.byType(ListTile).first;
      await tester.drag(activityItem, Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Verify delete action appears
      expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);
    });

    testWidgets('Add New Activity with iOS UI', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pumpAndSettle();

      // Verify iOS-style form
      expect(find.byType(CupertinoTextField), findsNWidgets(2)); // Title and description fields
      expect(find.byType(CupertinoButton), findsNWidgets(2)); // Save and Cancel buttons

      // Enter activity details
      await tester.enterText(find.byType(CupertinoTextField).first, 'Test Activity');
      await tester.enterText(find.byType(CupertinoTextField).last, 'Test Description');
      await tester.pumpAndSettle();

      // Save activity
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify activity was added
      expect(find.text('Test Activity'), findsOneWidget);
    });

    testWidgets('iOS Settings and Security', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(CupertinoIcons.settings));
      await tester.pumpAndSettle();

      // Verify iOS settings UI
      expect(find.byType(CupertinoListSection), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2)); // Notifications and security switches

      // Test security features
      final deviceSecurity = DeviceSecurity();
      final isJailbroken = await deviceSecurity.isJailbroken();
      expect(isJailbroken, false, reason: 'App should detect jailbroken devices');

      // Test SSL pinning
      final securityConfig = SecurityConfig();
      final isSSLPinningEnabled = await securityConfig.isSSLPinningEnabled();
      expect(isSSLPinningEnabled, true, reason: 'SSL pinning should be enabled');
    });

    testWidgets('iOS Activity Details and Navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on an activity
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verify iOS-style detail view
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      
      // Test iOS back gesture
      final gesture = await tester.createGesture();
      await gesture.addPointer(location: Offset(0, 300));
      await gesture.moveBy(Offset(300, 0));
      await tester.pumpAndSettle();

      // Verify returned to list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('iOS Notifications and Permissions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Go to settings
      await tester.tap(find.byIcon(CupertinoIcons.settings));
      await tester.pumpAndSettle();

      // Test notification toggle
      final notificationSwitch = find.byType(CupertinoSwitch).first;
      await tester.tap(notificationSwitch);
      await tester.pumpAndSettle();

      // Verify iOS permission dialog would appear (can't test actual dialog in integration test)
      expect(find.byType(CupertinoSwitch), findsOneWidget);
    });

    testWidgets('iOS App State and Background Behavior', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add an activity
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).first, 'Background Test');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Simulate app going to background
      await tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      // Simulate app returning to foreground
      await tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify activity data is preserved
      expect(find.text('Background Test'), findsOneWidget);
    });

    testWidgets('iOS Accessibility and VoiceOver', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify semantic labels for VoiceOver
      final semanticNodes = tester.getSemantics(find.byType(CupertinoApp));
      expect(semanticNodes, isNotEmpty);

      // Test dynamic text sizes
      await tester.binding.setAccessibilityFeatures(
        AccessibilityFeatures.boldText,
      );
      await tester.pumpAndSettle();

      // Verify UI elements are still accessible
      expect(find.byType(CupertinoButton), findsWidgets);
      expect(find.byType(CupertinoTextField), findsWidgets);
    });
  });
} 