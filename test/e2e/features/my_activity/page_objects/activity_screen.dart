import 'package:appium_flutter_server/appium_flutter_server.dart';

class ActivityScreen {
  // Element locators
  static const String activityList = 'activity_list';
  static const String addActivityButton = 'add_activity_button';
  static const String activityTitle = 'activity_title';
  static const String activityDescription = 'activity_description';
  static const String activityDate = 'activity_date';
  static const String activityTime = 'activity_time';
  static const String saveButton = 'save_button';
  static const String cancelButton = 'cancel_button';

  // New element locators
  static const String activityItem = 'activity_item_';
  static const String editButton = 'edit_button_';
  static const String deleteButton = 'delete_button_';
  static const String statusButton = 'status_button_';
  static const String confirmDeleteButton = 'confirm_delete_button';
  static const String activityStatus = 'activity_status_';
  static const String searchField = 'search_field';
  static const String filterButton = 'filter_button';

  // Common actions
  Future<void> addNewActivity() async {
    await FlutterDriver().tap(find.byValueKey(addActivityButton));
  }

  Future<Map<String, dynamic>> getStatusField() async {
    final statusField = await FlutterDriver().getText(find.byValueKey('status_field'));
    final isEnabled = await FlutterDriver().getAttribute(
      find.byValueKey('status_field'),
      'enabled',
    );
    return {
      'value': statusField,
      'enabled': isEnabled == 'true',
    };
  }

  Future<void> enterActivityDetails({
    required String title,
    required String description,
    required String date,
    required String time,
  }) async {
    await FlutterDriver().enterText(find.byValueKey(activityTitle), title);
    await FlutterDriver().enterText(find.byValueKey(activityDescription), description);
    await FlutterDriver().enterText(find.byValueKey(activityDate), date);
    await FlutterDriver().enterText(find.byValueKey(activityTime), time);

    // Verify status field is disabled and shows "Active"
    final statusField = await getStatusField();
    if (statusField['enabled'] || statusField['value'] != 'Active') {
      throw Exception('Status field should be disabled and show "Active" during activity creation');
    }
  }

  Future<void> saveActivity() async {
    await FlutterDriver().tap(find.byValueKey(saveButton));
  }

  Future<void> cancelActivity() async {
    await FlutterDriver().tap(find.byValueKey(cancelButton));
  }

  Future<bool> isActivityListVisible() async {
    return await FlutterDriver().isPresent(find.byValueKey(activityList));
  }

  // New methods for activity management
  Future<void> selectActivity(String activityId) async {
    await FlutterDriver().tap(find.byValueKey('$activityItem$activityId'));
  }

  Future<void> editActivity(String activityId) async {
    await FlutterDriver().tap(find.byValueKey('$editButton$activityId'));
  }

  Future<void> updateActivityDetails({
    String? title,
    String? description,
    String? date,
    String? time,
  }) async {
    if (title != null) {
      await FlutterDriver().clear(find.byValueKey(activityTitle));
      await FlutterDriver().enterText(find.byValueKey(activityTitle), title);
    }
    if (description != null) {
      await FlutterDriver().clear(find.byValueKey(activityDescription));
      await FlutterDriver().enterText(find.byValueKey(activityDescription), description);
    }
    if (date != null) {
      await FlutterDriver().clear(find.byValueKey(activityDate));
      await FlutterDriver().enterText(find.byValueKey(activityDate), date);
    }
    if (time != null) {
      await FlutterDriver().clear(find.byValueKey(activityTime));
      await FlutterDriver().enterText(find.byValueKey(activityTime), time);
    }
  }

  Future<void> toggleActivityStatus(String activityId) async {
    await FlutterDriver().tap(find.byValueKey('$statusButton$activityId'));
  }

  Future<String> getActivityStatus(String activityId) async {
    final statusElement = await FlutterDriver().getText(find.byValueKey('$activityStatus$activityId'));
    return statusElement;
  }

  Future<void> deleteActivity(String activityId) async {
    await FlutterDriver().tap(find.byValueKey('$deleteButton$activityId'));
    await FlutterDriver().tap(find.byValueKey(confirmDeleteButton));
  }

  Future<bool> isActivityPresent(String activityId) async {
    return await FlutterDriver().isPresent(find.byValueKey('$activityItem$activityId'));
  }

  Future<void> searchActivity(String query) async {
    await FlutterDriver().enterText(find.byValueKey(searchField), query);
  }

  Future<void> filterActivities(String filterType) async {
    await FlutterDriver().tap(find.byValueKey(filterButton));
    await FlutterDriver().tap(find.byValueKey('filter_$filterType'));
  }

  Future<List<String>> getFilteredResults() async {
    final activities = await FlutterDriver().getText(find.byValueKey(activityList));
    return activities.split('\n');
  }

  Future<void> clearAllActivities() async {
    while (await FlutterDriver().isPresent(find.byValueKey(deleteButton))) {
      await FlutterDriver().tap(find.byValueKey(deleteButton));
      await FlutterDriver().tap(find.byValueKey(confirmDeleteButton));
    }
  }

  Future<String> getErrorMessage() async {
    return await FlutterDriver().getText(find.byValueKey(errorMessage));
  }
} 