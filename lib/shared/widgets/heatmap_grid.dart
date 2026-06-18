import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/utils/date_utils.dart';

/// A GitHub-style contribution heatmap echoing the app's habit-grid logo motif.
///
/// Renders the last [weeks] weeks as columns of 7 day-cells, coloring each by
/// the 0–4 intensity returned by [level]. Includes an optional Less→More legend.
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.level,
    this.weeks = 18,
    this.cell = 14,
    this.gap = 4,
    this.showLegend = true,
  });

  /// Maps a calendar day to an intensity bucket 0 (empty) .. 4 (strongest).
  final int Function(DateTime day) level;
  final int weeks;
  final double cell;
  final double gap;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final today = DateKeys.stripTime(DateTime.now());
    final totalDays = weeks * 7;
    final start = today.subtract(Duration(days: totalDays - 1));

    final columns = <Widget>[];
    for (var w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (var d = 0; d < 7; d++) {
        final day = start.add(Duration(days: w * 7 + d));
        final isFuture = day.isAfter(today);
        final lvl = isFuture ? 0 : level(day).clamp(0, 4);
        cells.add(Padding(
          padding: EdgeInsets.only(bottom: d == 6 ? 0 : gap),
          child: _Cell(size: cell, color: context.palette.heatScale[lvl]),
        ));
      }
      columns.add(Padding(
        padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : gap),
        child: Column(children: cells),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(children: columns),
        ),
        if (showLegend) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                      )),
              const SizedBox(width: 6),
              for (final c in context.palette.heatScale)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _Cell(size: cell * 0.85, color: c),
                ),
              const SizedBox(width: 6),
              Text('More',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                      )),
            ],
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
