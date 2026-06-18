import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../models/habit.dart';

/// Thin persistence layer over a Hive `Box<String>` keyed by habit id.
/// Each value is the habit serialized to JSON.
class HabitRepository {
  Box<String> get _box => Hive.box<String>(AppConstants.habitsBox);

  List<Habit> getAll() {
    return _box.values.map(Habit.fromJson).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> save(Habit habit) async {
    await _box.put(habit.id, habit.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
