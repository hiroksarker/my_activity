import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_activity/main.dart' as app;
import 'package:my_activity/features/activities/models/activity.dart';
import 'package:my_activity/features/activities/models/activity_enums.dart';
import 'package:my_activity/features/home/widgets/activity_card.dart';
import 'package:provider/provider.dart';
import 'package:my_activity/features/activities/providers/activity_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing
  setUpAll(() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;

    // Get the database path and delete it
    final dbPath = join(await getDatabasesPath(), 'my_activity.db');
    try {
      await databaseFactory.deleteDatabase(dbPath);
    } catch (e) {
      // Ignore errors if database doesn't exist
    }
  });

  Future<void> addTestActivity(
    WidgetTester tester, {
    required String title,
    required String description,
    ActivityPriority priority = ActivityPriority.regular,
    String category = 'Work',
  }) async {
    // Tap the add button and wait for animation
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Find the form fields by their label text
    final titleField = find.widgetWithText(TextFormField, 'Title');
    final descriptionField = find.widgetWithText(TextFormField, 'Description');
    final categoryField = find.widgetWithText(TextFormField, 'Category');

    // Fill in the form
    await tester.enterText(titleField, title);
    await tester.enterText(descriptionField, description);
    await tester.enterText(categoryField, category);
    await tester.pumpAndSettle();

    // Verify status field is disabled and shows "Active"
    final statusField = find.widgetWithText(TextFormField, 'Status');
    expect(statusField, findsOneWidget);
    final statusFieldWidget = tester.widget<TextFormField>(statusField);
    expect(statusFieldWidget.enabled, false);
    expect(statusFieldWidget.initialValue, 'Active');

    // Select priority
    final priorityDropdown = find.widgetWithText(DropdownButtonFormField<ActivityPriority>, 'Priority');
    await tester.ensureVisible(priorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(priorityDropdown);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Find and tap the priority option
    final priorityOption = find.byWidgetPredicate(
      (widget) => widget is DropdownMenuItem<ActivityPriority> &&
          widget.value == priority &&
          widget.child is Text &&
          (widget.child as Text).data?.toLowerCase() == priority.toString().split('.').last.toLowerCase(),
    ).first;
    await tester.ensureVisible(priorityOption);
    await tester.pumpAndSettle();
    await tester.tap(priorityOption, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Submit the form
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the activity was added
    final activityCard = find.byType(ActivityCard).last;
    expect(activityCard, findsOneWidget);
    
    // Verify the activity card shows the correct title
    final titleText = find.descendant(
      of: activityCard,
      matching: find.text(title),
    );
    expect(titleText, findsOneWidget);

    // Verify the activity has both the active status icon and lock icon (for new activities)
    final statusIcon = find.descendant(
      of: activityCard,
      matching: find.byIcon(Icons.play_circle_outline),
    );
    expect(statusIcon, findsOneWidget);
    final lockIcon = find.descendant(
      of: activityCard,
      matching: find.byIcon(Icons.lock_outline),
    );
    expect(lockIcon, findsOneWidget);
  }

  Future<void> initializeApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Wait for the activity provider to initialize
    final BuildContext context = tester.element(find.byType(MaterialApp));
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    
    // Wait for initial data to load
    while (provider.isLoading || !provider.hasInitialized) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('Activity UI Tests', () {
    testWidgets('Initial Activity List View Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Verify the app bar
      expect(find.text('Activities'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify the FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('New Activity'), findsOneWidget);

      // Verify the activity list (empty at first)
      expect(find.byType(ActivityCard), findsNothing);
      expect(find.text('No activities found'), findsOneWidget);
    });

    testWidgets('Add Activity with Fixed Active Status Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add a task
      await addTestActivity(
        tester,
        title: 'New Task',
        description: 'This is a new task',
        priority: ActivityPriority.high,
      );

      // Verify the task was added with active status
      expect(find.text('New Task'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget); // Active status icon
      expect(find.byIcon(Icons.lock_outline), findsOneWidget); // Lock icon for new activities

      // Verify we can't change status during creation
      final statusField = find.widgetWithText(TextFormField, 'Status');
      expect(statusField, findsOneWidget);
      final statusFieldWidget = tester.widget<TextFormField>(statusField);
      expect(statusFieldWidget.enabled, false);
    });

    testWidgets('Add Activity with Different Priorities Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add a high priority task
      await addTestActivity(
        tester,
        title: 'High Priority Task',
        description: 'This is a high priority task',
        priority: ActivityPriority.high,
      );

      // Verify the task was added with active status and priority badge
      expect(find.text('High Priority Task'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget); // Active status icon
      expect(find.byIcon(Icons.lock_outline), findsOneWidget); // Lock icon
      expect(find.text('high'), findsOneWidget); // Priority badge text

      // Add a regular priority task
      await addTestActivity(
        tester,
        title: 'Regular Priority Task',
        description: 'This is a regular priority task',
        priority: ActivityPriority.regular,
      );

      // Verify both tasks are visible with active status and priority badges
      expect(find.text('Regular Priority Task'), findsOneWidget);
      expect(find.byType(ActivityCard), findsNWidgets(2));
      expect(find.byIcon(Icons.play_circle_outline), findsNWidgets(2)); // Both should have active status icon
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2)); // Both should have lock icon
      expect(find.text('regular'), findsOneWidget); // Priority badge text
    });

    testWidgets('Filter Activities Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add tasks with different priorities
      await addTestActivity(
        tester,
        title: 'High Priority Task',
        description: 'This is a high priority task',
        priority: ActivityPriority.high,
      );

      await addTestActivity(
        tester,
        title: 'Regular Priority Task',
        description: 'This is a regular priority task',
        priority: ActivityPriority.regular,
      );

      // Open the filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Filter by high priority
      final priorityFilter = find.widgetWithText(DropdownButtonFormField<ActivityPriority>, 'Priority');
      await tester.ensureVisible(priorityFilter);
      await tester.pumpAndSettle();
      await tester.tap(priorityFilter);
      await tester.pumpAndSettle();

      // Select high priority
      final highPriorityOption = find.text('high').last;
      await tester.tap(highPriorityOption);
      await tester.pumpAndSettle();

      // Filter is applied immediately, verify only high priority task is visible
      expect(find.text('High Priority Task'), findsOneWidget);
      expect(find.text('Regular Priority Task'), findsNothing);

      // Clear filter by selecting "All Priorities"
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(priorityFilter);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Priorities').first);
      await tester.pumpAndSettle();

      // Verify all tasks are visible again
      expect(find.text('High Priority Task'), findsOneWidget);
      expect(find.text('Regular Priority Task'), findsOneWidget);
    });

    testWidgets('Search Activities Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add tasks
      await addTestActivity(
        tester,
        title: 'Gym Session',
        description: 'Morning workout',
        priority: ActivityPriority.high,
      );

      await addTestActivity(
        tester,
        title: 'Team Meeting',
        description: 'Weekly sync',
        priority: ActivityPriority.regular,
      );

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search text
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Meeting');
      await tester.pumpAndSettle();

      // Verify only matching task is visible
      expect(find.text('Team Meeting'), findsOneWidget);
      expect(find.text('Gym Session'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Verify all tasks are visible again
      expect(find.text('Team Meeting'), findsOneWidget);
      expect(find.text('Gym Session'), findsOneWidget);
    });

    testWidgets('Edit Activity Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add a task
      await addTestActivity(
        tester,
        title: 'Original Task',
        description: 'Original description',
        priority: ActivityPriority.regular,
      );

      // Find and tap the edit button
      final editButton = find.descendant(
        of: find.byType(ActivityCard),
        matching: find.byIcon(Icons.edit_outlined),
      );
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Update the task
      final titleField = find.widgetWithText(TextFormField, 'Title');
      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      await tester.enterText(titleField, 'Updated Task');
      await tester.enterText(descriptionField, 'Updated description');
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the task was updated
      expect(find.text('Updated Task'), findsOneWidget);
      expect(find.text('Updated description'), findsOneWidget);
      expect(find.text('Original Task'), findsNothing);
    });

    testWidgets('Delete Activity Test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Add a task
      await addTestActivity(
        tester,
        title: 'Task to Delete',
        description: 'This task will be deleted',
        priority: ActivityPriority.regular,
      );

      // Find and tap the delete button
      final deleteButton = find.descendant(
        of: find.byType(ActivityCard),
        matching: find.byIcon(Icons.delete_outline),
      );
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the task was deleted
      expect(find.text('Task to Delete'), findsNothing);
      expect(find.byType(ActivityCard), findsNothing);
    });
  });
} 