import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../shared/widgets/streak_badge.dart';

/// A single habit row, tinted with the habit's own color across the whole
/// container (background + border + emoji tile + check ring). Swipe left to
/// delete; tap the body to open details.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  bool get _doneToday => habit.completedDates.contains(DateKeys.today());

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final streak = StreakCalculator.current(habit.completedDates);
    final surface = context.palette.surface;

    // Tint the whole card with the habit color, blended over the theme surface
    // so it reads correctly in both light and dark modes.
    final bg = Color.alphaBlend(
      color.withValues(alpha: _doneToday ? 0.18 : 0.10),
      surface,
    );
    final borderColor = color.withValues(alpha: _doneToday ? 0.6 : 0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Dismissible(
        key: ValueKey(habit.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        ),
        onDismissed: (_) => onDelete(),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(habit.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 3),
                        StreakBadge(streak: streak),
                      ],
                    ),
                  ),
                  CheckRing(done: _doneToday, color: color, onTap: onToggle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular tap-to-complete control: filled with the habit color + check
/// when done, a hollow outline otherwise.
class CheckRing extends StatelessWidget {
  const CheckRing({
    super.key,
    required this.done,
    required this.color,
    required this.onTap,
    this.size = 34,
  });

  final bool done;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          boxShadow: done
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]
              : null,
        ),
        child: done
            ? Icon(Icons.check_rounded, color: _onColor(color), size: size * 0.6)
            : null,
      ),
    );
  }

  /// Pick a readable check color for the filled ring based on the habit color.
  Color _onColor(Color c) {
    return ThemeData.estimateBrightnessForColor(c) == Brightness.dark
        ? Colors.white
        : const Color(0xFF0A1A0A);
  }
}
