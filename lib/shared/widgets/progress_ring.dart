import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A circular progress ring with an emerald gradient sweep and a soft glow,
/// matching the "Today's progress" hero in the design. Animates on value change.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 220,
    this.stroke = 16,
    this.center,
  });

  /// 0.0 – 1.0
  final double progress;
  final double size;
  final double stroke;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(value: value, stroke: stroke),
            child: Center(child: center),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.stroke});

  final double value;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;

    // Track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary.withValues(alpha: 0.10);
    canvas.drawCircle(center, radius, track);

    if (value <= 0) return;

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: start,
      endAngle: start + 2 * math.pi,
      colors: const [AppColors.primaryDeep, AppColors.primary, AppColors.primaryBright],
      stops: const [0.0, 0.6, 1.0],
      transform: GradientRotation(start),
    );

    // Glow underlay.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(arcRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(arcRect, start, sweep, false, glow);

    // Crisp arc.
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(arcRect);
    canvas.drawArc(arcRect, start, sweep, false, arc);

    // Leading dot.
    final dotAngle = start + sweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(
      dotCenter,
      stroke * 0.55,
      Paint()..color = AppColors.primaryBright,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.stroke != stroke;
}
