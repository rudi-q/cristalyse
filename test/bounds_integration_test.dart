import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse/src/core/util/bounds_calculator.dart';

void main() {
  group('Bounds Integration Tests', () {
    test('LinearScale calculateBounds works with geometry context', () {
      final barGeometry = BarGeometry();
      final lineGeometry = LineGeometry();

      // Test LinearScale with bar geometry (should use zero baseline)
      final barScale = LinearScale();
      barScale.setBounds([10.0, 20.0, 30.0], null, [barGeometry]);

      expect(barScale.domain[0], equals(0)); // Zero baseline for bars
      // Wilkinson will nice-ify the upper bound (33 → 30 or 35 or 40)
      expect(barScale.domain[1], greaterThanOrEqualTo(30.0));
      expect(barScale.domain[1], lessThanOrEqualTo(50.0));

      // Test LinearScale with line geometry (should use data-driven bounds)
      final lineScale = LinearScale();
      lineScale.setBounds([10.0, 20.0, 30.0], null, [lineGeometry]);

      // Wilkinson will produce nice bounds that cover the data with padding
      expect(lineScale.domain[0], lessThanOrEqualTo(10.0)); // Covers min
      expect(lineScale.domain[1], greaterThanOrEqualTo(30.0)); // Covers max
      // Should not start at zero for data-driven (line geometry)
      expect(lineScale.domain[0], greaterThan(0));
    });

    testWidgets('LinearScale respects limits precedence', (tester) async {
      // Test that limits passed to setBounds override internal limits
      final scale = LinearScale(limits: (5.0, 95.0));
      scale.setBounds([10.0, 20.0, 30.0], (0.0, 100.0), [LineGeometry()]);

      // Wilkinson will nice-ify within the provided limits
      expect(scale.domain[0], lessThanOrEqualTo(10.0)); // Covers data
      expect(scale.domain[1], greaterThanOrEqualTo(30.0)); // Covers data
      expect(scale.domain[0], greaterThanOrEqualTo(0.0)); // Respects min limit
      expect(scale.domain[1], lessThanOrEqualTo(100.0)); // Respects max limit
    });

    testWidgets(
        'LinearScale falls back to internal limits when setBounds limits null',
        (tester) async {
      // Test internal limits used when setBounds limits null
      final scale = LinearScale(limits: (5.0, 95.0));
      scale.setBounds([10.0, 20.0, 30.0], null, [BarGeometry()]);

      // Wilkinson will nice-ify within internal limits
      expect(scale.domain[0], lessThanOrEqualTo(10.0)); // Covers data
      expect(scale.domain[1], greaterThanOrEqualTo(30.0)); // Covers data
      expect(
          scale.domain[0], greaterThanOrEqualTo(5.0)); // Respects internal min
      expect(scale.domain[1], lessThanOrEqualTo(95.0)); // Respects internal max
    });

    group('Real-world bounds behavior', () {
      test('Stock price chart uses tight data-driven bounds', () {
        final stockPrices = [45.20, 46.15, 47.80, 46.95];
        final lineGeometry = LineGeometry();

        // Line chart should use data-driven bounds (tight around data)
        final scale = LinearScale();
        scale.setBounds(stockPrices, null, [lineGeometry]);

        // Wilkinson produces nice bounds covering data
        expect(scale.domain[0], lessThanOrEqualTo(45.20)); // Covers min
        expect(scale.domain[1], greaterThanOrEqualTo(47.80)); // Covers max

        // Verify it does NOT start at zero (that would be wrong for stock prices)
        expect(scale.domain[0], greaterThan(0));
      });

      test('Revenue bar chart uses zero baseline', () {
        final revenues = [2500000.0, 2800000.0, 3200000.0, 2900000.0];
        final barGeometry = BarGeometry();

        // Bar chart should use zero baseline for proper quantity comparison
        final scale = LinearScale();
        scale.setBounds(revenues, null, [barGeometry]);

        expect(scale.domain[0], equals(0)); // Must start at zero
        // Wilkinson will nice-ify max (3.52M → 4M or similar nice number)
        expect(scale.domain[1], greaterThanOrEqualTo(3200000.0));
        expect(scale.domain[1], lessThanOrEqualTo(5000000.0));
      });

      test('Survey data respects explicit 1-5 scale limits', () {
        final ratings = [4.2, 3.8, 4.5, 3.9];
        final barGeometry = BarGeometry();

        // Explicit limits override geometry behavior (bar would normally use zero baseline)
        final scale = LinearScale();
        scale.setBounds(ratings, (1.0, 5.0), [barGeometry]);

        // Wilkinson will nice-ify within explicit limits
        expect(scale.domain[0], greaterThanOrEqualTo(1.0)); // Respects min
        expect(scale.domain[1], lessThanOrEqualTo(5.0)); // Respects max
        expect(scale.domain[0], lessThanOrEqualTo(3.8)); // Covers data
        expect(scale.domain[1], greaterThanOrEqualTo(4.5)); // Covers data
      });
    });

    group('Multi-geometry priority', () {
      test('Bar + Line combo uses zero baseline (bar priority)', () {
        final values = [100000.0, 120000.0, 110000.0];
        final barGeometry = BarGeometry();
        final lineGeometry = LineGeometry();

        // When bar and line are combined, bar's zero baseline takes priority
        final scale = LinearScale();
        scale.setBounds(values, null, [barGeometry, lineGeometry]);

        expect(scale.domain[0], equals(0)); // Bar geometry wins
        // Wilkinson will nice-ify max (132K → 150K or similar)
        expect(scale.domain[1], greaterThanOrEqualTo(120000.0));
        expect(scale.domain[1], lessThanOrEqualTo(200000.0));
      });

      test('Line + Point combo uses data-driven with padding', () {
        final values = [45.2, 47.1, 46.8];
        final lineGeometry = LineGeometry();
        final pointGeometry = PointGeometry();

        // Both are data-driven, so bounds should be tight around data with padding
        final scale = LinearScale();
        scale.setBounds(values, null, [lineGeometry, pointGeometry]);

        // Wilkinson produces nice bounds covering data
        expect(scale.domain[0], lessThanOrEqualTo(45.2)); // Covers min
        expect(scale.domain[1], greaterThanOrEqualTo(47.1)); // Covers max
        expect(scale.domain[0], greaterThan(0)); // Not zero baseline
      });

      test('Area + Line uses zero baseline (area priority)', () {
        final values = [800.0, 900.0, 850.0];
        final areaGeometry = AreaGeometry();
        final lineGeometry = LineGeometry();

        // Area geometry has zero baseline behavior, should win over line
        final scale = LinearScale();
        scale.setBounds(values, null, [areaGeometry, lineGeometry]);

        expect(scale.domain[0], equals(0)); // Area geometry wins
        // Wilkinson will nice-ify max (990 → 1000 or similar)
        expect(scale.domain[1], greaterThanOrEqualTo(900.0));
        expect(scale.domain[1], lessThanOrEqualTo(1500.0));
      });
    });

    group('Limits precedence', () {
      test('Explicit limits override geometry behavior', () {
        final values = [10.0, 20.0, 30.0];
        final barGeometry = BarGeometry();

        // Bar would normally start at zero, but explicit limits override
        final scale = LinearScale();
        scale.setBounds(values, (5.0, 50.0), [barGeometry]);

        // Wilkinson will nice-ify within explicit limits
        expect(scale.domain[0], lessThanOrEqualTo(10.0)); // Covers data
        expect(scale.domain[1], greaterThanOrEqualTo(30.0)); // Covers data
        expect(
            scale.domain[0], greaterThanOrEqualTo(5.0)); // Respects min limit
        expect(scale.domain[1], lessThanOrEqualTo(50.0)); // Respects max limit
      });

      test('Partial limits (min only) use geometry behavior for max', () {
        final values = [45.2, 47.1, 48.9];
        final lineGeometry = LineGeometry();

        // Min specified, max should use data-driven behavior
        final scale = LinearScale();
        scale.setBounds(values, (40.0, null), [lineGeometry]);

        // Wilkinson will nice-ify respecting partial limit
        expect(scale.domain[0],
            greaterThanOrEqualTo(40.0)); // Respects explicit min
        expect(scale.domain[0], lessThanOrEqualTo(45.2)); // Covers data
        expect(scale.domain[1], greaterThanOrEqualTo(48.9)); // Covers data
      });

      test('Partial limits (max only) use geometry behavior for min', () {
        final values = [45.2, 47.1, 48.9];
        final lineGeometry = LineGeometry();

        // Max specified, min should use data-driven behavior
        final scale = LinearScale();
        scale.setBounds(values, (null, 50.0), [lineGeometry]);

        // Wilkinson will nice-ify respecting partial limit
        expect(scale.domain[0], lessThanOrEqualTo(45.2)); // Covers data
        expect(
            scale.domain[1], lessThanOrEqualTo(50.0)); // Respects explicit max
        expect(scale.domain[1], greaterThanOrEqualTo(48.9)); // Covers data
      });
    });

    group('Real geometry behavior specification', () {
      // These tests verify that real geometry classes each return the expected BoundsBehavior

      test('point geometry uses data-driven behavior', () {
        expect(PointGeometry().getBoundsBehavior(), BoundsBehavior.dataDriven);
      });

      test('line geometry uses data-driven behavior', () {
        expect(LineGeometry().getBoundsBehavior(), BoundsBehavior.dataDriven);
      });

      test('bar geometry uses zero baseline behavior', () {
        expect(BarGeometry().getBoundsBehavior(), BoundsBehavior.zeroBaseline);
      });

      test('area geometry uses zero baseline behavior', () {
        expect(AreaGeometry().getBoundsBehavior(), BoundsBehavior.zeroBaseline);
      });

      test('bubble geometry uses data-driven behavior', () {
        expect(BubbleGeometry().getBoundsBehavior(), BoundsBehavior.dataDriven);
      });

      test('heat map geometry uses data-driven behavior', () {
        expect(
            HeatMapGeometry().getBoundsBehavior(), BoundsBehavior.dataDriven);
      });

      test('pie geometry uses not applicable behavior', () {
        expect(PieGeometry().getBoundsBehavior(), BoundsBehavior.notApplicable);
      });

      test('progress bar geometry uses not applicable behavior', () {
        expect(ProgressGeometry().getBoundsBehavior(),
            BoundsBehavior.notApplicable);
      });
    });
  });
}
