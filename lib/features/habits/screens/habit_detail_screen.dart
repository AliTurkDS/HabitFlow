import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../shared/widgets/heatmap_grid.dart';
import '../../../shared/widgets/stat_card.dart';
import '../controller/habit_controller.dart';
import 'add_habit_screen.dart';

/// Detail view for a single habit: streak hero, lifetime stats, completion
/// heatmap, and edit/delete actions.
class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitController>(
      builder: (context, controller, _) {
        final matches = controller.habits.where((h) => h.id == habitId);
        final Habit? habit = matches.isEmpty ? null : matches.first;

        // Habit was deleted while open — leave the screen.
        if (habit == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final color = Color(habit.colorValue);
        final current = StreakCalculator.current(habit.completedDates);
        final longest = StreakCalculator.longest(habit.completedDates);
        final total = habit.completedDates.length;
        final doneToday = habit.completedDates.contains(DateKeys.today());

        return Scaffold(
          appBar: AppBar(
            title: Text(habit.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddHabitScreen(habit: habit)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, controller),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.palette.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(habit.emoji, style: const TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.flame, size: 32),
                        const SizedBox(width: 6),
                        Text(
                          '$current',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      current == 1 ? 'day streak' : 'day streak running',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.palette.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => controller.toggleComplete(habit.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: doneToday
                            ? context.palette.surfaceHigh
                            : AppColors.primary,
                        foregroundColor: doneToday
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.onPrimary,
                      ),
                      icon: Icon(doneToday
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded),
                      label: Text(doneToday ? 'Done today' : 'Mark done today'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '$longest',
                      label: 'Best streak',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.flame,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(value: '$total', label: 'Total done')),
                ],
              ),
              const SizedBox(height: 32),
              Text('Activity', style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.palette.border),
                ),
                child: HeatmapGrid(
                  level: (day) =>
                      habit.completedDates.contains(DateKeys.of(day)) ? 3 : 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, HabitController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: const Text('This will remove the habit and its history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deleteHabit(habitId);
    }
  }
}
