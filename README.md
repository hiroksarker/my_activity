# My Activity

A Flutter application for tracking and managing your daily activities, tasks, finances, and personal growth.

## Features

- 📱 Modern Material Design 3 UI
- 📊 Activity tracking with progress visualization
- 📅 Calendar integration
- 💰 Finance tracking
- ✅ Task management
- 👤 User profile management

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- iOS development tools (for iOS development)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/my_activity.git
cd my_activity
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── app/              # Application configuration and setup
├── core/             # Core utilities and constants
├── features/         # Feature-based modules
│   ├── calendar/     # Calendar feature
│   ├── finances/     # Finance tracking feature
│   ├── home/         # Home screen feature
│   ├── profile/      # User profile feature
│   └── tasks/        # Task management feature
├── shared/           # Shared widgets and utilities
└── main.dart         # Application entry point
```

## Development

### Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) and uses [flutter_lints](https://pub.dev/packages/flutter_lints) for code analysis.

### Architecture

The project follows a feature-first architecture with clean separation of concerns:
- Each feature is self-contained in its own directory
- Shared components are placed in the `shared` directory
- Core utilities and constants are in the `core` directory

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- All contributors who have helped shape this project
