import 'package:appium_flutter_server/appium_flutter_server.dart';
import '../page_objects/activity_screen.dart';

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

  group('Activity Creation Tests', () {
    test('should create new activity successfully', () async {
      // Verify activity list is visible
      expect(await activityScreen.isActivityListVisible(), true);

      // Add new activity
      await activityScreen.addNewActivity();

      // Enter activity details
      await activityScreen.enterActivityDetails(
        title: 'Test Activity',
        description: 'This is a test activity',
        date: '2024-03-20',
        time: '10:00 AM',
      );

      // Save activity
      await activityScreen.saveActivity();

      // Verify activity list is still visible
      expect(await activityScreen.isActivityListVisible(), true);
    });

    test('should cancel activity creation', () async {
      // Add new activity
      await activityScreen.addNewActivity();

      // Enter some details
      await activityScreen.enterActivityDetails(
        title: 'Test Activity',
        description: 'This is a test activity',
        date: '2024-03-20',
        time: '10:00 AM',
      );

      // Cancel activity
      await activityScreen.cancelActivity();

      // Verify activity list is still visible
      expect(await activityScreen.isActivityListVisible(), true);
    });
  });
} 