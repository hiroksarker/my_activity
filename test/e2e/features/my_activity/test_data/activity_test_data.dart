class ActivityTestData {
  // Activity Types
  static const Map<String, Map<String, dynamic>> activityTypes = {
    'work': {
      'title': 'Work Meeting',
      'description': 'Team sync meeting',
      'category': 'work',
      'priority': 'high',
      'expectedDuration': '60',
    },
    'personal': {
      'title': 'Gym Session',
      'description': 'Weekly workout routine',
      'category': 'personal',
      'priority': 'medium',
      'expectedDuration': '90',
    },
    'health': {
      'title': 'Doctor Appointment',
      'description': 'Annual checkup',
      'category': 'health',
      'priority': 'high',
      'expectedDuration': '30',
    },
    'social': {
      'title': 'Dinner with Friends',
      'description': 'Catch up with college friends',
      'category': 'social',
      'priority': 'low',
      'expectedDuration': '120',
    },
  };

  // Valid Activity Data
  static const Map<String, dynamic> validActivity = {
    'title': 'Valid Activity',
    'description': 'This is a valid activity description',
    'date': '2024-03-20',
    'time': '10:00 AM',
    'category': 'work',
    'priority': 'high',
    'expectedDuration': '60',
    'location': 'Office',
    'reminder': true,
  };

  // Invalid Activity Data Scenarios
  static const Map<String, Map<String, dynamic>> invalidScenarios = {
    'emptyTitle': {
      'title': '',
      'description': 'Valid description',
      'date': '2024-03-20',
      'time': '10:00 AM',
      'expectedError': 'Title is required',
    },
    'emptyDescription': {
      'title': 'Valid Title',
      'description': '',
      'date': '2024-03-20',
      'time': '10:00 AM',
      'expectedError': 'Description is required',
    },
    'invalidDate': {
      'title': 'Valid Title',
      'description': 'Valid description',
      'date': 'invalid-date',
      'time': '10:00 AM',
      'expectedError': 'Invalid date format',
    },
    'pastDate': {
      'title': 'Valid Title',
      'description': 'Valid description',
      'date': '2020-01-01',
      'time': '10:00 AM',
      'expectedError': 'Date cannot be in the past',
    },
    'invalidTime': {
      'title': 'Valid Title',
      'description': 'Valid description',
      'date': '2024-03-20',
      'time': '25:00',
      'expectedError': 'Invalid time format',
    },
    'longTitle': {
      'title': 'A' * 101, // 101 characters
      'description': 'Valid description',
      'date': '2024-03-20',
      'time': '10:00 AM',
      'expectedError': 'Title too long',
    },
    'longDescription': {
      'title': 'Valid Title',
      'description': 'A' * 501, // 501 characters
      'date': '2024-03-20',
      'time': '10:00 AM',
      'expectedError': 'Description too long',
    },
  };

  // Activity Status Transitions
  static const List<Map<String, dynamic>> statusTransitions = [
    {
      'from': 'pending',
      'to': 'in_progress',
      'valid': true,
    },
    {
      'from': 'in_progress',
      'to': 'completed',
      'valid': true,
    },
    {
      'from': 'in_progress',
      'to': 'cancelled',
      'valid': true,
    },
    {
      'from': 'completed',
      'to': 'in_progress',
      'valid': false,
    },
    {
      'from': 'cancelled',
      'to': 'in_progress',
      'valid': false,
    },
  ];

  // Search Test Data
  static const List<Map<String, dynamic>> searchTestData = [
    {
      'title': 'Morning Meeting',
      'description': 'Daily standup',
      'searchTerm': 'meeting',
      'shouldFind': true,
    },
    {
      'title': 'Gym Workout',
      'description': 'Cardio session',
      'searchTerm': 'yoga',
      'shouldFind': false,
    },
    {
      'title': 'Project Review',
      'description': 'Q1 project review meeting',
      'searchTerm': 'review',
      'shouldFind': true,
    },
  ];

  // Filter Test Data
  static const Map<String, List<Map<String, dynamic>>> filterTestData = {
    'status': [
      {'status': 'pending', 'count': 2},
      {'status': 'in_progress', 'count': 1},
      {'status': 'completed', 'count': 3},
      {'status': 'cancelled', 'count': 1},
    ],
    'priority': [
      {'priority': 'high', 'count': 3},
      {'priority': 'medium', 'count': 2},
      {'priority': 'low', 'count': 2},
    ],
    'category': [
      {'category': 'work', 'count': 4},
      {'category': 'personal', 'count': 2},
      {'category': 'health', 'count': 1},
      {'category': 'social', 'count': 1},
    ],
  };
} 