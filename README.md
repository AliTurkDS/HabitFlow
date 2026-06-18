# HabitFlow 🎯

An AI-powered habit & routine tracker built with Flutter. Create daily habits,
keep your streaks alive, see your progress in charts, and get AI-generated habit
suggestions from a goal.

## Features

| Feature | Status |
| --- | --- |
| ✅ Create habits with custom emoji + color | Done |
| 🔥 Streak tracking (current + longest) | Done |
| 📊 Weekly completion chart (fl_chart) | Done |
| 🤖 AI habit suggestions (Claude API) | Done |
| 🔔 Daily reminders (local notifications) | Wired up — see TODO below |
| 💾 Offline persistence (Hive) | Done |
| 🌗 Light & dark theme | Done |

## Project structure

```
lib/
├── main.dart                      # App entry — Hive + notifications init
├── app.dart                       # MaterialApp + Provider wiring
├── core/
│   ├── constants/app_constants.dart
│   ├── theme/                     # app_colors.dart, app_theme.dart
│   ├── utils/date_utils.dart      # DateKeys + StreakCalculator
│   └── services/
│       ├── ai_service.dart        # Claude API (raw HTTP) + offline fallback
│       └── notification_service.dart
├── data/
│   ├── models/habit.dart          # Habit model (JSON-serialized)
│   └── repositories/habit_repository.dart
└── features/
    ├── habits/
    │   ├── controller/habit_controller.dart   # ChangeNotifier state
    │   ├── screens/                # home_screen, add_habit_screen
    │   └── widgets/habit_card.dart
    └── stats/screens/stats_screen.dart
```

## Architecture

- **State management:** `provider` + `ChangeNotifier` (`HabitController`).
- **Persistence:** `hive` — each habit is stored as a JSON string in a
  `Box<String>`, so no code generation / `build_runner` step is needed.
- **AI:** `AiService` calls the Claude Messages API (`claude-opus-4-8`) over raw
  HTTP, since Dart has no official Anthropic SDK. Without an API key it returns a
  curated offline suggestion list, so the feature works out of the box.

## Getting started

```bash
flutter pub get
flutter run
```

### Enabling AI suggestions

The AI service reads the Claude API key from a compile-time define:

```bash
flutter run --dart-define=CLAUDE_API_KEY=sk-ant-...
```

Leave it unset to use the built-in offline fallback suggestions.

## TODO

- [ ] Add Android `POST_NOTIFICATIONS` + `SCHEDULE_EXACT_ALARM` permissions to
      `android/app/src/main/AndroidManifest.xml`, then call
      `NotificationService.instance.requestPermissions()` and
      `scheduleDaily(...)` when a habit reminder time is set.
- [ ] Add a reminder-time picker to the Add Habit screen.
- [ ] Streak heatmap (GitHub-style) on the stats screen.
- [ ] Edit existing habits.
```
