import 'package:flutter/material.dart';

/// App-wide constants and configuration.
class AppConstants {
  AppConstants._();

  static const String appName = 'HabitFlow';

  // Hive box names
  static const String habitsBox = 'habits_box';
  static const String settingsBox = 'settings_box';

  // Settings keys
  static const String keyThemeMode = 'theme_mode';

  // Notifications
  static const String notifChannelId = 'habit_reminders';
  static const String notifChannelName = 'Habit Reminders';
  static const String notifChannelDesc =
      'Reminders to keep your habit streaks alive';

  /// Set your Claude API key here (or load from --dart-define / .env in prod).
  /// Leave empty to use the built-in offline suggestion fallback.
  static const String claudeApiKey = String.fromEnvironment('CLAUDE_API_KEY');
  static const String claudeModel = 'claude-opus-4-8';
  static const String claudeApiUrl = 'https://api.anthropic.com/v1/messages';
}

/// A small curated palette of emoji icons users can pick for a habit.
const List<String> kHabitEmojis = [
  '💧', '🏃', '📚', '🧘', '💪', '🥗', '😴', '✍️',
  '🎯', '🎨', '🎸', '💊', '🚭', '🧹', '☎️', '🌱',
];

/// Accent colors a habit can be tagged with (emerald-leaning "Lush Zenith").
const List<Color> kHabitColors = [
  Color(0xFF22C55E), // emerald
  Color(0xFF38BDF8), // sky
  Color(0xFFF97316), // orange
  Color(0xFFA78BFA), // violet
  Color(0xFFF472B6), // pink
  Color(0xFF2DD4BF), // teal
  Color(0xFFFBBF24), // amber
  Color(0xFFF87171), // red
];
