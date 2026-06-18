import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme-aware semantic colors that aren't covered by [ColorScheme].
///
/// Surfaces, borders, muted text and the heatmap scale all need a light and a
/// dark variant so the "Lush Zenith" look holds up in both themes. Access via
/// `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.textSecondary,
    required this.textMuted,
    required this.heatScale,
  });

  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color textSecondary;
  final Color textMuted;
  final List<Color> heatScale;

  static const dark = AppPalette(
    surface: AppColors.surface,
    surfaceHigh: AppColors.surfaceHigh,
    border: AppColors.border,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    heatScale: AppColors.heatScale,
  );

  static const light = AppPalette(
    surface: AppColors.surfaceLight,
    surfaceHigh: Color(0xFFEAF3E8),
    border: AppColors.borderLight,
    textSecondary: AppColors.textSecondaryLight,
    textMuted: Color(0xFF94A790),
    heatScale: [
      Color(0xFFE7EFE5), // empty
      Color(0xFFBDE5C7),
      Color(0xFF6FD08C),
      Color(0xFF34B45E),
      Color(0xFF16A34A),
    ],
  );

  @override
  AppPalette copyWith({
    Color? surface,
    Color? surfaceHigh,
    Color? border,
    Color? textSecondary,
    Color? textMuted,
    List<Color>? heatScale,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      heatScale: heatScale ?? this.heatScale,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      heatScale: [
        for (var i = 0; i < heatScale.length; i++)
          Color.lerp(heatScale[i], other.heatScale[i], t)!,
      ],
    );
  }
}

/// Convenience accessor: `context.palette.surface`, etc.
extension PaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
