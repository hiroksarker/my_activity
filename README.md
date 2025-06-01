# My Activity

A modern Flutter app for tracking activities, tasks, finances, and travel, featuring a beautiful Material 3 UI and robust local SQLite storage.

## ✨ Features (with details)

### 1. Modern UI & Navigation
- Material 3 design, vibrant gradients, and attractive icons.
- Bottom navigation bar for quick access to:
  - **My Activity** (tasks & activities)
  - **Finances** (transactions & summaries)
  - **Travel Hub** (trips, budgets, itineraries)

### 2. My Activity
- Track daily activities and tasks.
- Visualize progress with charts and cards.
- Add, edit, and delete tasks/activities.
- Calendar integration for scheduling.

### 3. Finances
- Record income and expenses.
- Categorize transactions.
- View transaction history and summaries.
- Financial dashboard with breakdowns and charts.
- Edit/delete transactions with confirmation dialogs.

### 4. Travel Hub (Budgets)
- Plan multi-destination trips.
- Set budgets, base currency, and add trip members.
- Add and split expenses by traveler.
- Attach documents (tickets, bookings, etc.).
- Build detailed itineraries (activities and time slots).
- View trip overviews with floating cards and destination chips.
- Currency conversion and offline support.

### 5. User Profile
- Manage personal info and preferences.
- View activity and finance stats.

### 6. Robust Local Storage
- All data stored locally using SQLite.
- Automatic schema migrations and error handling.

### 7. Beautiful, Consistent UX
- Reusable widgets (ActionIcon, ConfirmationDialog, GreenPillsWallpaper, etc.) and responsive layouts.

## 📸 Screenshots

*Below are placeholder links for screenshots. Please add your screenshots in the assets/images folder and update the links accordingly.*

- **Home Screen**  
  ![Home](assets/images/home.png)

- **Finances**  
  ![Finances](assets/images/finances.png)

- **Trip Overview**  
  ![Trip Overview](assets/images/trip_overview.png)

- **Expense Dialog**  
  ![Expense Dialog](assets/images/expense_dialog.png)

- **User Profile**  
  ![User Profile](assets/images/profile.png)

## 🗂️ Project Structure

```
lib/
├── features/
│   ├── activity/      # Activity tracking
│   ├── budgets/       # Travel hub (trips, expenses, itineraries)
│   ├── finances/      # Finance tracking
│   ├── tasks/         # Task management
│   ├── calendar/      # Calendar integration
│   ├── profile/       # User profile
│   └── home/          # Navigation & main screens
├── shared/            # Shared widgets/utilities
└── main.dart          # App entry point
```

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code (with Flutter extensions)
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

## 🧩 Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework.
- Material Design team for the design system.
- All contributors who have helped shape this project.
