import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../controller/habit_controller.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

/// Today: daily progress hero + the list of habits, split into active and done.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: const AppWordmark(fontSize: 24),
          ),
          floatingActionButton: controller.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openAdd(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New habit',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
          body: controller.isEmpty
              ? _EmptyState(onAdd: () => _openAdd(context))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  children: [
                    _ProgressHero(
                      progress: controller.todayProgress,
                      done: controller.completedToday.length,
                      total: controller.habits.length,
                    ),
                    const SizedBox(height: 28),
                    if (controller.pendingToday.isNotEmpty) ...[
                      const _SectionLabel('ACTIVE HABITS'),
                      const SizedBox(height: 8),
                      for (final habit in controller.pendingToday)
                        HabitCard(
                          habit: habit,
                          onToggle: () => controller.toggleComplete(habit.id),
                          onDelete: () => controller.deleteHabit(habit.id),
                          onTap: () => _openDetail(context, habit.id),
                        ),
                    ],
                    if (controller.completedToday.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel('COMPLETED · ${controller.completedToday.length}'),
                      const SizedBox(height: 8),
                      for (final habit in controller.completedToday)
                        HabitCard(
                          habit: habit,
                          onToggle: () => controller.toggleComplete(habit.id),
                          onDelete: () => controller.deleteHabit(habit.id),
                          onTap: () => _openDetail(context, habit.id),
                        ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habitId: id)),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.progress,
    required this.done,
    required this.total,
  });

  final double progress;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        children: [
          Text(
            "Today's progress",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          ProgressRing(
            progress: progress,
            size: 200,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$done of $total done today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.palette.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text('No habits yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 8),
            Text(
              'Start small. Add your first habit and\nbuild the streak day by day.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New habit'),
            ),
          ],
        ),
      ),
    );
  }
}
