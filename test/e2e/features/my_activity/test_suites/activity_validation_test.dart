import 'package:appium_flutter_server/appium_flutter_server.dart';
import '../page_objects/activity_screen.dart';
import '../test_data/activity_test_data.dart';

void main() {
  late FlutterDriver driver;
  late ActivityScreen activityScreen;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    activityScreen = ActivityScreen();
  });

  tearDownAll(() async {
    await driver.close();
  });

  group('Activity Validation Tests', () {
    test('should validate all activity types', () async {
      for (final type in ActivityTestData.activityTypes.entries) {
        await activityScreen.addNewActivity();
        await activityScreen.enterActivityDetails(
          title: type.value['title'],
          description: type.value['description'],
          date: '2024-03-20',
          time: '10:00 AM',
        );
        await activityScreen.saveActivity();
        
        // Verify activity was created successfully
        expect(await activityScreen.isActivityPresent('1'), true);
        
        // Cleanup
        await activityScreen.deleteActivity('1');
      }
    });

    test('should validate all invalid scenarios', () async {
      for (final scenario in ActivityTestData.invalidScenarios.entries) {
        await activityScreen.addNewActivity();
        await activityScreen.enterActivityDetails(
          title: scenario.value['title'],
          description: scenario.value['description'],
          date: scenario.value['date'],
          time: scenario.value['time'],
        );
        await activityScreen.saveActivity();

        // Verify error message
        final errorMessage = await activityScreen.getErrorMessage();
        expect(errorMessage, equals(scenario.value['expectedError']));

        // Cancel the invalid activity
        await activityScreen.cancelActivity();
      }
    });

    test('should validate new activity status is always active', () async {
      // Create a test activity
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Status Validation Test',
        description: 'Testing that new activities are always active',
        date: '2024-03-20',
        time: '10:00 AM',
      );

      // Verify status field is disabled and shows "Active"
      final statusField = await activityScreen.getStatusField();
      expect(statusField.enabled, false);
      expect(statusField.value, 'Active');

      // Save the activity
      await activityScreen.saveActivity();

      // Verify the activity was created with active status
      final activityStatus = await activityScreen.getActivityStatus('1');
      expect(activityStatus.toLowerCase(), 'active');

      // Cleanup
      await activityScreen.deleteActivity('1');
    });

    test('should validate status transitions only after creation', () async {
      // Create a test activity
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Status Transition Test',
        description: 'Testing status transitions after creation',
        date: '2024-03-20',
        time: '10:00 AM',
      );
      await activityScreen.saveActivity();

      final testActivityId = '1';

      // Verify initial status is active
      expect(await activityScreen.getActivityStatus(testActivityId).toLowerCase(), 'active');

      for (final transition in ActivityTestData.statusTransitions) {
        // Attempt status transition
        await activityScreen.toggleActivityStatus(testActivityId);
        final newStatus = await activityScreen.getActivityStatus(testActivityId);

        if (transition['valid']) {
          expect(newStatus.toLowerCase(), equals(transition['to']));
        } else {
          expect(newStatus.toLowerCase(), equals(transition['from']));
          // Verify error message for invalid transition
          final errorMessage = await activityScreen.getErrorMessage();
          expect(errorMessage, contains('Invalid status transition'));
        }
      }

      // Cleanup
      await activityScreen.deleteActivity(testActivityId);
    });

    test('should validate search functionality', () async {
      // Create test activities
      for (final searchData in ActivityTestData.searchTestData) {
        await activityScreen.addNewActivity();
        await activityScreen.enterActivityDetails(
          title: searchData['title'],
          description: searchData['description'],
          date: '2024-03-20',
          time: '10:00 AM',
        );
        await activityScreen.saveActivity();
      }

      // Test each search term
      for (final searchData in ActivityTestData.searchTestData) {
        await activityScreen.searchActivity(searchData['searchTerm']);
        final searchResults = await activityScreen.getSearchResults();
        
        if (searchData['shouldFind']) {
          expect(searchResults, contains(searchData['title']));
        } else {
          expect(searchResults, isNot(contains(searchData['title'])));
        }
      }

      // Cleanup
      await activityScreen.clearAllActivities();
    });

    test('should validate filtering functionality', () async {
      // Create test activities for each category
      for (final category in ActivityTestData.filterTestData['category']!) {
        for (var i = 0; i < category['count']; i++) {
          await activityScreen.addNewActivity();
          await activityScreen.enterActivityDetails(
            title: '${category['category']} Activity $i',
            description: 'Test activity',
            date: '2024-03-20',
            time: '10:00 AM',
          );
          await activityScreen.saveActivity();
        }
      }

      // Test each filter type
      for (final filterType in ActivityTestData.filterTestData.keys) {
        for (final filter in ActivityTestData.filterTestData[filterType]!) {
          await activityScreen.filterActivities(filterType, filter[filterType]);
          final filteredResults = await activityScreen.getFilteredResults();
          expect(filteredResults.length, equals(filter['count']));
        }
      }

      // Cleanup
      await activityScreen.clearAllActivities();
    });

    test('should validate activity constraints', () async {
      // Test maximum activities limit
      for (var i = 0; i < 100; i++) {
        await activityScreen.addNewActivity();
        await activityScreen.enterActivityDetails(
          title: 'Activity $i',
          description: 'Test activity',
          date: '2024-03-20',
          time: '10:00 AM',
        );
        await activityScreen.saveActivity();
      }

      // Try to add one more activity
      await activityScreen.addNewActivity();
      await activityScreen.enterActivityDetails(
        title: 'Extra Activity',
        description: 'Should not be allowed',
        date: '2024-03-20',
        time: '10:00 AM',
      );
      await activityScreen.saveActivity();

      // Verify error message
      final errorMessage = await activityScreen.getErrorMessage();
      expect(errorMessage, contains('Maximum activities limit reached'));

      // Cleanup
      await activityScreen.clearAllActivities();
    });

    test('should validate concurrent activity creation', () async {
      // Try to create multiple activities simultaneously
      final activities = [
        {'title': 'Activity 1', 'time': '10:00 AM'},
        {'title': 'Activity 2', 'time': '10:00 AM'},
        {'title': 'Activity 3', 'time': '10:00 AM'},
      ];

      for (final activity in activities) {
        await activityScreen.addNewActivity();
        await activityScreen.enterActivityDetails(
          title: activity['title'],
          description: 'Test activity',
          date: '2024-03-20',
          time: activity['time'],
        );
      }

      // Verify conflict detection
      for (var i = 1; i < activities.length; i++) {
        await activityScreen.saveActivity();
        final errorMessage = await activityScreen.getErrorMessage();
        expect(errorMessage, contains('Time slot conflict'));
        await activityScreen.cancelActivity();
      }

      // Cleanup
      await activityScreen.clearAllActivities();
    });
  });
} 