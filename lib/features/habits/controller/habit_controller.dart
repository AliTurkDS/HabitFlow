import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../data/repositories/habit_repository.dart';

/// Owns the list of habits and exposes mutations to the UI.
/// Backed by [HabitRepository] for persistence.
class HabitController extends ChangeNotifier {
  HabitController(this._repo) {
    _habits = _repo.getAll();
  }

  final HabitRepository _repo;
  final _uuid = const Uuid();

  late List<Habit> _habits;
  List<Habit> get habits => List.unmodifiable(_habits);

  bool get isEmpty => _habits.isEmpty;

  /// Habits not yet completed today.
  List<Habit> get pendingToday {
    final today = DateKeys.today();
    return _habits.where((h) => !h.completedDates.contains(today)).toList();
  }

  /// Habits already completed today.
  List<Habit> get completedToday {
    final today = DateKeys.today();
    return _habits.where((h) => h.completedDates.contains(today)).toList();
  }

  double get todayProgress {
    if (_habits.isEmpty) return 0;
    return completedToday.length / _habits.length;
  }

  Future<void> addHabit({
    required String title,
    required String emoji,
    required int colorValue,
    HabitFrequency frequency = HabitFrequency.daily,
    int? reminderMinutes,
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title.trim(),
      emoji: emoji,
      colorValue: colorValue,
      frequency: frequency,
      reminderMinutes: reminderMinutes,
      createdAt: DateTime.now(),
    );
    _habits.add(habit);
    await _repo.save(habit);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    _habits[index] = habit;
    await _repo.save(habit);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _repo.delete(id);
    notifyListeners();
  }

  /// Marks/unmarks a habit as done for [date] (defaults to today).
  Future<void> toggleComplete(String id, {DateTime? date}) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final key = DateKeys.of(date ?? DateTime.now());
    final habit = _habits[index];
    final dates = Set<String>.from(habit.completedDates);
    dates.contains(key) ? dates.remove(key) : dates.add(key);

    final updated = habit.copyWith(completedDates: dates);
    _habits[index] = updated;
    await _repo.save(updated);
    notifyListeners();
  }
}
