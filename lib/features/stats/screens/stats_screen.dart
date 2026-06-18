import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../shared/widgets/heatmap_grid.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../habits/controller/habit_controller.dart';

/// Trends: headline stats, a 7-day completion chart, and a year-style heatmap.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  /// Number of habits completed on [day] across the whole library.
  int _completionsOn(List<Habit> habits, DateTime day) {
    final key = DateKeys.of(day);
    return habits.where((h) => h.completedDates.contains(key)).length;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HabitController>();
    final habits = controller.habits;

    final days = DateKeys.lastDays(7);
    final perDay = days.map((d) => _completionsOn(habits, d)).toList();

    final bestStreak = habits.isEmpty
        ? 0
        : habits
            .map((h) => StreakCalculator.longest(h.completedDates))
            .reduce((a, b) => a > b ? a : b);
    final totalCompletions =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Your stats')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Row(
            children: [
              Expanded(child: StatCard(value: '${habits.length}', label: 'Habits')),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '$bestStreak',
                  label: 'Best streak',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.flame,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: '$totalCompletions', label: 'Total done')),
            ],
          ),
          const SizedBox(height: 32),
          Text('Last 7 days', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _Panel(
            child: SizedBox(
              height: 200,
              child: _WeeklyChart(days: days, values: perDay),
            ),
          ),
          const SizedBox(height: 32),
          Text('Activity', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _Panel(
            child: HeatmapGrid(
              level: (day) {
                if (habits.isEmpty) return 0;
                final count = _completionsOn(habits, day);
                if (count == 0) return 0;
                final ratio = count / habits.length;
                return (ratio * 4).ceil().clamp(1, 4);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.border),
      ),
      child: child,
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.days, required this.values});

  final List<DateTime> days;
  final List<int> values;

  static const _weekday = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal < 1 ? 1 : maxVal) + 1.0;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _weekday[days[i].weekday - 1],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDeep, AppColors.primaryBright],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
