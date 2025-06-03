import 'package:appium_flutter_server/appium_flutter_server.dart';
import '../page_objects/activity_screen.dart';

void main() {
  late FlutterDriver driver;
  late ActivityScreen activityScreen;
  String testActivityId = '';

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    activityScreen = ActivityScreen();
  });

  tearDownAll(() async {
    await driver.close();
  });

  group('Activity Management Tests', () {
    test('should create, edit, update status, and delete an activity', () async {
      // Step 1: Create a new activity
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Test Activity',
        description: 'Initial description',
        date: '2024-03-20',
        time: '10:00 AM',
      );
      await activityScreen.saveActivity();

      // Get the activity ID (you might need to implement this based on your app's logic)
      testActivityId = '1'; // This should be dynamically generated or retrieved

      // Verify activity was created
      expect(await activityScreen.isActivityPresent(testActivityId), true);

      // Step 2: Edit the activity
      await activityScreen.editActivity(testActivityId);
      await activityScreen.updateActivityDetails(
        title: 'Updated Activity',
        description: 'Updated description',
        date: '2024-03-21',
        time: '11:00 AM',
      );
      await activityScreen.saveActivity();

      // Verify activity was updated
      expect(await activityScreen.isActivityPresent(testActivityId), true);

      // Step 3: Update activity status
      final initialStatus = await activityScreen.getActivityStatus(testActivityId);
      await activityScreen.toggleActivityStatus(testActivityId);
      final updatedStatus = await activityScreen.getActivityStatus(testActivityId);
      expect(updatedStatus, isNot(equals(initialStatus)));

      // Step 4: Delete the activity
      await activityScreen.deleteActivity(testActivityId);
      expect(await activityScreen.isActivityPresent(testActivityId), false);
    });

    test('should handle activity search and filtering', () async {
      // Create multiple activities
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Searchable Activity',
        description: 'This should be searchable',
        date: '2024-03-20',
        time: '10:00 AM',
      );
      await activityScreen.saveActivity();

      // Test search functionality
      await activityScreen.searchActivity('Searchable');
      // Verify search results (implementation depends on your app's search UI)

      // Test filtering
      await activityScreen.filterActivities('completed');
      // Verify filtered results (implementation depends on your app's filter UI)
    });

    test('should handle activity status transitions', () async {
      // Create a new activity
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Status Test Activity',
        description: 'Testing status changes',
        date: '2024-03-20',
        time: '10:00 AM',
      );
      await activityScreen.saveActivity();

      testActivityId = '2'; // This should be dynamically generated or retrieved

      // Test status transitions
      final statuses = ['pending', 'in_progress', 'completed', 'cancelled'];
      String previousStatus = '';

      for (final status in statuses) {
        await activityScreen.toggleActivityStatus(testActivityId);
        final currentStatus = await activityScreen.getActivityStatus(testActivityId);
        expect(currentStatus, isNot(equals(previousStatus)));
        previousStatus = currentStatus;
      }

      // Cleanup
      await activityScreen.deleteActivity(testActivityId);
    });

    test('should handle activity validation', () async {
      // Test creating activity with invalid data
      await activityScreen.addNewActivity();
      
      // Try to save without required fields
      await activityScreen.saveActivity();
      // Verify error messages (implementation depends on your app's validation UI)

      // Try to save with invalid date
      await activityScreen.enterActivityDetails(
        title: 'Invalid Activity',
        description: 'Testing validation',
        date: 'invalid-date',
        time: 'invalid-time',
      );
      await activityScreen.saveActivity();
      // Verify error messages

      // Cancel the invalid activity
      await activityScreen.cancelActivity();
    });
  });
} 