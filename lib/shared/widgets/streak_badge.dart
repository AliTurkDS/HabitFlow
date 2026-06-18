import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';

/// A flame + day-count pill used to surface a habit's current streak.
/// Renders muted "Start your streak" copy when the streak is zero.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak, this.compact = false});

  final int streak;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) {
      return Text(
        'Start your streak',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.textSecondary,
            ),
      );
    }

    final label = compact ? '$streak' : '$streak day streak';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.local_fire_department_rounded,
            color: AppColors.flame, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.flame,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
