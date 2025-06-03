# My Activity - Personal Activity Management System

A comprehensive Flutter application for managing personal activities, tasks, finances, and more. This application helps users organize their daily activities, track expenses, manage documents, and plan their personal growth.

## Project Structure

```
lib/
├── features/           # Feature-based modules
│   ├── activities/     # Activity management
│   ├── auth/          # Authentication
│   ├── budgets/       # Budget management
│   ├── calendar/      # Calendar functionality
│   ├── documents/     # Document management
│   ├── expenses/      # Expense tracking
│   ├── family/        # Family management
│   ├── finances/      # Financial management
│   ├── home/          # Home screen
│   ├── itinerary/     # Travel planning
│   ├── ledger/        # Financial ledger
│   ├── personal_growth/ # Personal development
│   ├── profile/       # User profile
│   ├── settings/      # App settings
│   ├── study_planner/ # Study planning
│   ├── tasks/         # Task management
│   └── user/          # User management
├── core/              # Core functionality
├── database/          # Database operations
├── di/               # Dependency injection
├── shared/           # Shared components
├── utils/            # Utility functions
└── widgets/          # Reusable widgets

test/                 # Root test directory
├── e2e/             # End-to-end tests
│   └── features/    # Feature-specific e2e tests
├── integration/     # Integration tests
│   ├── activity_ui_test.dart
│   └── other_integration_tests.dart
├── unit/            # Unit tests
│   ├── activities/
│   ├── auth/
│   └── other_features/
└── helpers/         # Test utilities

integration_test/     # UI and integration tests
```

## Features

### 1. Activity Management (`features/activities/`)
- Create, update, and delete activities
- Set activity priorities
- Track activity status
- Filter and search activities
- Activity categorization

### 2. Authentication (`features/auth/`)
- User authentication
- Secure login/logout
- Password management
- Session handling

### 3. Budget Management (`features/budgets/`)
- Create and manage budgets
- Track spending against budgets
- Budget categories
- Budget reports

### 4. Calendar (`features/calendar/`)
- Event scheduling
- Activity timeline
- Calendar views
- Reminders

### 5. Document Management (`features/documents/`)
- Document storage
- File organization
- Document sharing
- Version control

### 6. Expense Tracking (`features/expenses/`)
- Expense logging
- Category management
- Receipt scanning
- Expense reports

### 7. Family Management (`features/family/`)
- Family member profiles
- Shared activities
- Family calendar
- Resource sharing

### 8. Financial Management (`features/finances/`)
- Financial tracking
- Income/expense management
- Financial reports
- Investment tracking

### 9. Home Screen (`features/home/`)
- Dashboard
- Quick actions
- Activity overview
- Notifications

### 10. Itinerary Planning (`features/itinerary/`)
- Trip planning
- Schedule management
- Location tracking
- Travel expenses

### 11. Personal Growth (`features/personal_growth/`)
- Goal setting
- Progress tracking
- Habit formation
- Achievement tracking

### 12. Profile Management (`features/profile/`)
- User profiles
- Settings management
- Preferences
- Account management

### 13. Study Planning (`features/study_planner/`)
- Study schedule
- Course management
- Progress tracking
- Resource organization

### 14. Task Management (`features/tasks/`)
- Task creation and assignment
- Priority management
- Deadline tracking
- Task categories

## Testing Strategy

### Test Organization
- All tests are organized under the root `test/` directory:
  ```
  test/
  ├── e2e/             # End-to-end tests
  │   └── features/    # Feature-specific e2e tests
  ├── integration/     # Integration tests
  │   ├── activity_ui_test.dart
  │   └── other_integration_tests.dart
  ├── unit/            # Unit tests
  │   ├── activities/
  │   ├── auth/
  │   └── other_features/
  └── helpers/         # Test utilities
  ```

### Test Types
1. **Unit Tests** (`test/unit/`)
   - Test individual functions and methods
   - Organized by feature in subdirectories
   - Focus on business logic and data processing

2. **Widget Tests** (`test/widget/`)
   - Test UI components
   - Verify widget rendering and interactions
   - Located in feature-specific subdirectories

3. **Integration Tests** (`test/integration/`)
   - Test feature interactions
   - Verify feature workflows
   - Include UI tests for complex interactions

4. **End-to-End Tests** (`test/e2e/`)
   - Test complete user flows
   - Located in `test/e2e/features/`
   - Verify application behavior from user perspective

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/integration/activity_ui_test.dart

# Run tests with coverage
flutter test --coverage
```

## Development Setup

1. **Prerequisites**
   - Flutter SDK
   - Dart SDK
   - Android Studio / Xcode
   - Git

2. **Installation**
   ```bash
   git clone [repository-url]
   cd my_activity
   flutter pub get
   ```

3. **Environment Setup**
   - Copy `.env.example` to `.env`
   - Configure environment variables
   - Set up Firebase (if needed)

4. **Running the App**
   ```bash
   flutter run
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework.
- Material Design team for the design system.
- All contributors who have helped shape this project.
