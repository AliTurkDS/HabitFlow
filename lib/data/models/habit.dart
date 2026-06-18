import 'dart:convert';

/// How often a habit should be performed.
enum HabitFrequency { daily, weekly }

/// A single habit the user is tracking.
///
/// Persisted as JSON in a Hive `Box<String>`, so no generated TypeAdapter
/// (and no build_runner step) is required.
class Habit {
  final String id;
  final String title;
  final String emoji;
  final int colorValue;
  final HabitFrequency frequency;

  /// Optional daily reminder time, stored as minutes since midnight.
  final int? reminderMinutes;

  /// Dates (yyyy-MM-dd) on which the habit was completed.
  final Set<String> completedDates;

  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    this.frequency = HabitFrequency.daily,
    this.reminderMinutes,
    Set<String>? completedDates,
    required this.createdAt,
  }) : completedDates = completedDates ?? <String>{};

  Habit copyWith({
    String? title,
    String? emoji,
    int? colorValue,
    HabitFrequency? frequency,
    int? reminderMinutes,
    bool clearReminder = false,
    Set<String>? completedDates,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'colorValue': colorValue,
        'frequency': frequency.name,
        'reminderMinutes': reminderMinutes,
        'completedDates': completedDates.toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as String,
        title: map['title'] as String,
        emoji: map['emoji'] as String? ?? '🎯',
        colorValue: map['colorValue'] as int,
        frequency: HabitFrequency.values.firstWhere(
          (f) => f.name == map['frequency'],
          orElse: () => HabitFrequency.daily,
        ),
        reminderMinutes: map['reminderMinutes'] as int?,
        completedDates: (map['completedDates'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toSet(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  String toJson() => jsonEncode(toMap());

  factory Habit.fromJson(String source) =>
      Habit.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
