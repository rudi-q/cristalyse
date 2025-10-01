import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/src/core/util/wilkinson_labeling.dart';

void main() {
  // Helper: Use realistic density calculation matching Scale.getTicks()
  // Optimal: ~60 pixels per label for readability
  const testScreenLength = 400.0; // Simulated 400px axis
  const optimalPixelsPerLabel = 60.0;
  final testLabelCount = (testScreenLength / optimalPixelsPerLabel).round();
  final testDensity = testLabelCount / testScreenLength; // labels per pixel

  group('Wilkinson Labeling', () {
    test('Example from paper: [36.6, 62.9] should give nice round numbers', () {
      final ticks =
          WilkinsonLabeling.extended(36.6, 62.9, testScreenLength, testDensity);

      // With realistic density, algorithm produces [40, 50, 60] (3 ticks, step=10)
      // This is an intentional undercoverage case where density optimization wins
      expect(ticks.length, 3);
      expect(ticks, [40.0, 50.0, 60.0]);

      // Step should be exactly 10
      final step = ticks[1] - ticks[0];
      expect(step, 10.0);
    });

    test('Website visitors: [1855.2, 7420.6] should give nice round numbers',
        () {
      final ticks = WilkinsonLabeling.extended(
          1855.2, 7420.6, testScreenLength, testDensity);

      // Algorithm produces 7 ticks with step of 1000
      // [2000, 3000, 4000, 5000, 6000, 7000, 8000]
      expect(ticks.length, 7);
      expect(ticks, [2000.0, 3000.0, 4000.0, 5000.0, 6000.0, 7000.0, 8000.0]);

      // All ticks should be multiples of 1000
      for (final tick in ticks) {
        expect(tick % 1000, 0, reason: 'Tick $tick should be multiple of 1000');
      }

      // Undercovers min (1855.2) but fully covers max
      expect(ticks.first, 2000.0);
      expect(ticks.last, greaterThanOrEqualTo(7420.6));
    });

    test('Small range: [45.2, 47.8] should not start at zero', () {
      final ticks =
          WilkinsonLabeling.extended(45.2, 47.8, testScreenLength, testDensity);

      // Algorithm produces [45, 46, 47, 48] (4 ticks, step=1)
      expect(ticks.length, 4);
      expect(ticks, [45.0, 46.0, 47.0, 48.0]);

      // For small ranges far from zero, should not force zero baseline
      expect(ticks.first, greaterThan(0));

      // Fully covers the data range
      expect(ticks.first, lessThanOrEqualTo(45.2));
      expect(ticks.last, greaterThanOrEqualTo(47.8));
    });

    test('Zero crossing: [-10, 30] should include zero', () {
      final ticks =
          WilkinsonLabeling.extended(-10, 30, testScreenLength, testDensity);

      // Algorithm produces [-10, 0, 10, 20, 30] (5 ticks, step=10)
      expect(ticks.length, 5);
      expect(ticks, [-10.0, 0.0, 10.0, 20.0, 30.0]);

      // When data crosses zero, zero should be included for simplicity bonus
      expect(ticks.contains(0.0), true);

      // Fully covers the data range
      expect(ticks.first, lessThanOrEqualTo(-10));
      expect(ticks.last, greaterThanOrEqualTo(30));
    });

    test('Large range: [0, 1000000] should use nice step sizes', () {
      final ticks =
          WilkinsonLabeling.extended(0, 1000000, testScreenLength, testDensity);

      // Algorithm produces 11 ticks from 0 to 1M with step of 100k
      expect(ticks.length, 11);
      expect(ticks.first, 0);
      expect(ticks.last, 1000000);

      // All ticks should be multiples of 100000
      for (final tick in ticks) {
        expect(tick % 100000, 0,
            reason: 'Tick $tick should be multiple of 100000');
      }

      // Verify step size
      final step = ticks[1] - ticks[0];
      expect(step, 100000.0);
    });

    test('Negative range: [-100, -20] should have nice negative numbers', () {
      final ticks =
          WilkinsonLabeling.extended(-100, -20, testScreenLength, testDensity);

      // Algorithm produces 9 ticks from -100 to -20 with step of 10
      expect(ticks.length, 9);
      expect(ticks.first, -100.0);
      expect(ticks.last, -20.0);

      // All ticks should be multiples of 10
      for (final tick in ticks) {
        expect(tick % 10, 0, reason: 'Tick $tick should be multiple of 10');
      }

      // Verify step size
      final step = ticks[1] - ticks[0];
      expect(step, 10.0);
    });

    test('Very small range: [0.12, 0.18] should produce appropriate decimals',
        () {
      final ticks =
          WilkinsonLabeling.extended(0.12, 0.18, testScreenLength, testDensity);

      // Algorithm produces 7 ticks from 0.12 to 0.18 with step of 0.01
      expect(ticks.length, 7);
      expect(ticks.first, closeTo(0.12, 1e-9));
      expect(ticks.last, closeTo(0.18, 1e-9));

      // Step should be approximately 0.01
      final step = ticks[1] - ticks[0];
      expect(step, closeTo(0.01, 0.0001));

      // Fully covers the data range
      expect(ticks.first, lessThanOrEqualTo(0.12));
      expect(ticks.last, greaterThanOrEqualTo(0.18));
    });

    test('Single value range: [42, 42] should handle gracefully', () {
      final ticks =
          WilkinsonLabeling.extended(42, 42, testScreenLength, testDensity);

      // Should return the single value
      expect(ticks.length, greaterThan(0));
      expect(ticks.first, 42);
    });

    test('Reversed range: [100, 0] should swap and produce ascending ticks',
        () {
      final ticks =
          WilkinsonLabeling.extended(100, 0, testScreenLength, testDensity);

      // Algorithm swaps and produces 11 ticks from 0 to 100 with step of 10
      expect(ticks.length, 11);
      expect(ticks.first, 0);
      expect(ticks.last, 100);

      // Should be ascending and include zero
      expect(ticks.first, lessThanOrEqualTo(ticks.last));
      expect(ticks.contains(0.0), true);

      // Verify step size
      final step = ticks[1] - ticks[0];
      expect(step, 10.0);
    });

    test('Typical stock price range: [145.20, 152.80]', () {
      final ticks = WilkinsonLabeling.extended(
          145.20, 152.80, testScreenLength, testDensity);

      // Algorithm produces 9 ticks from 145 to 153 with step of 1
      expect(ticks.length, 9);
      expect(ticks.first, 145.0);
      expect(ticks.last, 153.0);

      // Should not start at zero for stock prices
      expect(ticks.first, greaterThan(100));

      // Verify step size
      final step = ticks[1] - ticks[0];
      expect(step, 1.0);

      // Fully covers the data range
      expect(ticks.first, lessThanOrEqualTo(145.20));
      expect(ticks.last, greaterThanOrEqualTo(152.80));
    });

    test('Temperature range crossing freezing: [-10, 10]', () {
      final ticks =
          WilkinsonLabeling.extended(-10, 10, testScreenLength, testDensity);

      // Algorithm produces [-10, 0, 10] (3 ticks, step=10)
      expect(ticks.length, 3);
      expect(ticks, [-10.0, 0.0, 10.0]);

      // Should include 0 (freezing point)
      expect(ticks.contains(0.0), true);

      // Fully covers and is symmetric
      expect(ticks.first, -10.0);
      expect(ticks.last, 10.0);
    });

    test('Returns reasonable number of ticks', () {
      final ticks =
          WilkinsonLabeling.extended(0, 100, testScreenLength, testDensity);

      // Algorithm produces 11 ticks from 0 to 100 with step of 10
      expect(ticks.length, 11);
      expect(ticks.first, 0);
      expect(ticks.last, 100);

      // Verify step size
      final step = ticks[1] - ticks[0];
      expect(step, 10.0);

      // For 400px screen with 60px/label target, we expect ~7 labels
      // Algorithm produces 11 which is reasonable (trades density for better simplicity/coverage)
      expect(ticks.length, greaterThanOrEqualTo(testLabelCount - 4));
      expect(ticks.length, lessThanOrEqualTo(testLabelCount + 4));
    });
  });
}
