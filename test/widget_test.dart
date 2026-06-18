import 'package:flutter_test/flutter_test.dart';

import 'package:habitflow/core/utils/date_utils.dart';

void main() {
  group('StreakCalculator', () {
    test('empty set has no streak', () {
      expect(StreakCalculator.current({}), 0);
      expect(StreakCalculator.longest({}), 0);
    });

    test('counts consecutive days ending today', () {
      final today = DateTime.now();
      final dates = {
        DateKeys.of(today),
        DateKeys.of(today.subtract(const Duration(days: 1))),
        DateKeys.of(today.subtract(const Duration(days: 2))),
      };
      expect(StreakCalculator.current(dates), 3);
    });

    test('longest finds the best run', () {
      final dates = {
        '2026-01-01',
        '2026-01-02',
        '2026-01-03',
        '2026-01-10',
      };
      expect(StreakCalculator.longest(dates), 3);
    });
  });
}
