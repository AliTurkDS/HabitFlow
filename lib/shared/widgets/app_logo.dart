import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The "HabitFlow" wordmark — "Habit" in the foreground color, "Flow" emerald.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.fontSize = 24});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.titleLarge?.color;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(text: 'Habit', style: TextStyle(color: color)),
          const TextSpan(text: 'Flow', style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}

/// A small rounded-square emblem echoing the logo: a check inside a tinted tile.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBright, AppColors.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: size * 0.4,
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, color: AppColors.onPrimary, size: size * 0.6),
    );
  }
}
