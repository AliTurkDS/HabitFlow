import 'package:flutter/material.dart';

/// Central color palette for HabitFlow — "Lush Zenith" emerald design system.
///
/// A dark-first, bio-digital aesthetic: deep near-black greens layered with
/// emerald accents, with flame-orange reserved exclusively for streaks.
class AppColors {
  AppColors._();

  // ── Brand / emerald ───────────────────────────────────────────────
  static const Color primary = Color(0xFF22C55E); // emerald
  static const Color primaryBright = Color(0xFF4ADE80); // light emerald
  static const Color primaryDeep = Color(0xFF16A34A);
  static const Color accent = Color(0xFF4ADE80);

  /// Streaks only — sharp thermal contrast against the cool green base.
  static const Color flame = Color(0xFFF97316);
  static const Color flameBright = Color(0xFFFBBF24);

  // ── Semantic ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFFF6B6B);

  // ── Dark surfaces (primary aesthetic) ─────────────────────────────
  static const Color background = Color(0xFF050D05); // base
  static const Color surface = Color(0xFF0D1A0D); // cards
  static const Color surfaceHigh = Color(0xFF152415); // elevated
  static const Color border = Color(0xFF1A2E1A); // 1px card borders
  static const Color textPrimary = Color(0xFFDBE6D5);
  static const Color textSecondary = Color(0xFF8BA889);
  static const Color textMuted = Color(0xFF5E7A5C);

  // ── Light surfaces (optional light theme) ─────────────────────────
  static const Color backgroundLight = Color(0xFFF3F8F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2EBE0);
  static const Color textPrimaryLight = Color(0xFF0D1A0D);
  static const Color textSecondaryLight = Color(0xFF5E7A5C);

  /// On-emerald foreground (dark text on bright emerald buttons).
  static const Color onPrimary = Color(0xFF052E12);

  /// Contribution-heatmap intensity scale (0 = empty .. 4 = strongest).
  static const List<Color> heatScale = [
    Color(0xFF112011), // empty
    Color(0xFF14532D),
    Color(0xFF16A34A),
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
  ];

  /// Emoji-tile / habit accent palette (emerald-leaning, all readable on dark).
  static const List<Color> habitPalette = [
    Color(0xFF22C55E), // emerald
    Color(0xFF38BDF8), // sky
    Color(0xFFF97316), // orange
    Color(0xFFA78BFA), // violet
    Color(0xFFF472B6), // pink
    Color(0xFF2DD4BF), // teal
    Color(0xFFFBBF24), // amber
    Color(0xFFF87171), // red
  ];
}
