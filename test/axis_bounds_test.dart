import 'package:cristalyse/src/core/geometry.dart';
import 'package:cristalyse/src/core/util/bounds_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

// Test geometries for bounds behavior testing
class TestZeroBaselineGeometry extends Geometry {
  TestZeroBaselineGeometry() : super(yAxis: YAxis.primary, interactive: false);

  @override
  BoundsBehavior getBoundsBehavior() => BoundsBehavior.zeroBaseline;
}

class TestDataDrivenGeometry extends Geometry {
  TestDataDrivenGeometry() : super(yAxis: YAxis.primary, interactive: false);

  @override
  BoundsBehavior getBoundsBehavior() => BoundsBehavior.dataDriven;
}

class TestNotApplicableGeometry extends Geometry {
  TestNotApplicableGeometry() : super(yAxis: YAxis.primary, interactive: false);

  @override
  BoundsBehavior getBoundsBehavior() => BoundsBehavior.notApplicable;
}

void main() {
  group('BoundsCalculator', () {
    group('calculateBounds', () {
      test('handles empty values', () {
        final bounds = BoundsCalculator.calculateBounds([], null, []);
        expect(bounds.min, equals(0));
        expect(bounds.max, equals(1));
      });

      test('uses explicit limits when fully specified', () {
        final values = [10.0, 20.0, 30.0];
        final limits = (5.0, 35.0);
        final bounds = BoundsCalculator.calculateBounds(values, limits, []);

        expect(bounds.min, equals(5.0));
        expect(bounds.max, equals(35.0));
      });

      test('uses partial limits with auto-calculation', () {
        final values = [10.0, 20.0, 30.0];
        final geometries = [TestDataDrivenGeometry()];

        // Test explicit min, auto max
        const (double?, double?) limitsMinOnly = (5.0, null);
        var bounds =
            BoundsCalculator.calculateBounds(values, limitsMinOnly, geometries);
        expect(bounds.min, equals(5.0));
        expect(bounds.max, greaterThan(30.0)); // Should include padding

        // Test auto min, explicit max
        const (double?, double?) limitsMaxOnly = (null, 35.0);
        bounds =
            BoundsCalculator.calculateBounds(values, limitsMaxOnly, geometries);
        expect(bounds.min, lessThan(10.0)); // Should include padding
        expect(bounds.max, equals(35.0));
      });
    });

    group('behavior-aware defaults', () {
      test('zero baseline behavior for positive data', () {
        final values = [10.0, 20.0, 30.0];
        final geometries = [TestZeroBaselineGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        expect(bounds.min, equals(0)); // Zero baseline
        expect(bounds.max, equals(30.0 * 1.1)); // 10% padding above max
      });

      test('zero baseline behavior for negative data', () {
        final values = [-30.0, -20.0, -10.0];
        final geometries = [TestZeroBaselineGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        expect(bounds.min, equals(-30.0 * 1.1)); // 10% padding below min
        expect(bounds.max, equals(0)); // Zero baseline
      });

      test('zero baseline behavior handles mixed positive/negative data', () {
        final values = [-10.0, 5.0, 20.0];
        final geometries = [TestZeroBaselineGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        expect(
            bounds.min, equals(-10.0 * 1.1)); // Include zero, extend negative
        expect(bounds.max, equals(20.0 * 1.1)); // Include zero, extend positive
      });

      test('data-driven behavior uses tight bounds with padding', () {
        final values = [45.0, 47.0, 50.0];
        final geometries = [TestDataDrivenGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should use 5% padding on data range
        final expectedPadding = (50.0 - 45.0) * 0.05; // 0.25
        expect(bounds.min, closeTo(45.0 - expectedPadding, 0.01));
        expect(bounds.max, closeTo(50.0 + expectedPadding, 0.01));
      });

      test('not applicable behavior returns ignored bounds', () {
        final values = [25.0, 35.0, 40.0];
        final geometries = [TestNotApplicableGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should return ignored bounds since these charts don't use continuous X/Y axes
        expect(bounds.min, equals(0.0));
        expect(bounds.max, equals(0.0));
      });

      test('mixed behaviors prioritize zero baseline over data-driven', () {
        final values = [10.0, 20.0, 30.0];
        final geometries = [
          TestZeroBaselineGeometry(),
          TestDataDrivenGeometry()
        ];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should prioritize zero baseline behavior over data-driven behavior
        expect(bounds.min, equals(0)); // Zero baseline wins
        expect(bounds.max, equals(30.0 * 1.1)); // Zero baseline style padding
      });

      test('unknown geometries default to data-driven bounds', () {
        final values = [5.0, 15.0, 25.0];
        final geometries = <Geometry>[]; // No known geometries

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should default to data-driven bounds
        final expectedPadding = (25.0 - 5.0) * 0.05; // 1.0
        expect(bounds.min, closeTo(5.0 - expectedPadding, 0.01));
        expect(bounds.max, closeTo(25.0 + expectedPadding, 0.01));
      });
    });

    group('edge cases', () {
      test('handles single value at zero', () {
        final values = [0.0];
        final geometries = [TestDataDrivenGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        expect(bounds.min, equals(-0.5));
        expect(bounds.max, equals(0.5));
      });

      test('handles single non-zero value', () {
        final values = [10.0];
        final geometries = [TestDataDrivenGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should use 10% padding for single values
        expect(bounds.min, equals(9.0));
        expect(bounds.max, equals(11.0));
      });

      test('handles identical values', () {
        final values = [15.0, 15.0, 15.0];
        final geometries = [TestDataDrivenGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should use 10% padding for identical values
        expect(bounds.min, equals(13.5));
        expect(bounds.max, equals(16.5));
      });

      test('handles very small values', () {
        final values = [0.001, 0.002, 0.003];
        final geometries = [TestDataDrivenGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should maintain precision for small values
        final expectedPadding = (0.003 - 0.001) * 0.05; // 0.0001
        expect(bounds.min, closeTo(0.001 - expectedPadding, 0.000001));
        expect(bounds.max, closeTo(0.003 + expectedPadding, 0.000001));
      });

      test('handles very large values', () {
        final values = [1000000.0, 2000000.0, 3000000.0];
        final geometries = [TestZeroBaselineGeometry()];

        final bounds =
            BoundsCalculator.calculateBounds(values, null, geometries);

        // Should handle large numbers correctly
        expect(bounds.min, equals(0)); // Zero baseline
        expect(bounds.max, equals(3000000.0 * 1.1)); // 10% padding
      });
    });

    group('precedence order', () {
      test('explicit limits override geometry defaults', () {
        final values = [10.0, 20.0, 30.0];
        final geometries = [TestZeroBaselineGeometry()];
        final limits = (5.0, 35.0);

        final bounds =
            BoundsCalculator.calculateBounds(values, limits, geometries);

        // Should use explicit limits instead of zero baseline geometry defaults
        expect(bounds.min, equals(5.0));
        expect(bounds.max, equals(35.0));
      });

      test('partial limits combine with geometry defaults correctly', () {
        final values = [10.0, 20.0, 30.0];
        final geometries = [TestZeroBaselineGeometry()];
        final limits = (null, 50.0); // Only explicit max

        final bounds =
            BoundsCalculator.calculateBounds(values, limits, geometries);

        // Should use geometry default for min, explicit limit for max
        expect(bounds.min, equals(0)); // Zero baseline
        expect(bounds.max, equals(50.0)); // Explicit limit
      });
    });
  });

  group('behavior precedence and collection', () {
    test('mixed behaviors prioritize zero baseline correctly', () {
      final values = [10.0, 20.0, 30.0];
      final mixedGeometries = [
        TestDataDrivenGeometry(),
        TestZeroBaselineGeometry()
      ];

      final bounds =
          BoundsCalculator.calculateBounds(values, null, mixedGeometries);

      // Should use zero baseline behavior despite having data-driven geometries
      expect(bounds.min, equals(0));
      expect(bounds.max, equals(30.0 * 1.1));
    });

    test('all data-driven behaviors use data-driven bounds', () {
      final values = [15.0, 18.0, 25.0];
      final dataDrivenGeometries = [
        TestDataDrivenGeometry(),
        TestDataDrivenGeometry()
      ];

      final bounds =
          BoundsCalculator.calculateBounds(values, null, dataDrivenGeometries);

      final expectedPadding = (25.0 - 15.0) * 0.05;
      expect(bounds.min, closeTo(15.0 - expectedPadding, 0.01));
      expect(bounds.max, closeTo(25.0 + expectedPadding, 0.01));
    });

    test('not applicable behaviors return ignored bounds', () {
      final values = [20.0, 30.0, 40.0];
      final notApplicableGeometries = [TestNotApplicableGeometry()];

      final bounds = BoundsCalculator.calculateBounds(
          values, null, notApplicableGeometries);

      // Should return ignored bounds since these charts don't use continuous axes
      expect(bounds.min, equals(0.0));
      expect(bounds.max, equals(0.0));
    });

    test('empty geometry list defaults to data-driven behavior', () {
      final values = [5.0, 15.0, 25.0];
      final emptyGeometries = <Geometry>[];

      final bounds =
          BoundsCalculator.calculateBounds(values, null, emptyGeometries);

      final expectedPadding = (25.0 - 5.0) * 0.05;
      expect(bounds.min, closeTo(5.0 - expectedPadding, 0.01));
      expect(bounds.max, closeTo(25.0 + expectedPadding, 0.01));
    });

    test('ignored bounds have highest precedence over explicit limits', () {
      final values = [20.0, 30.0, 40.0];
      final notApplicableGeometries = [TestNotApplicableGeometry()];
      final explicitLimits = (10.0, 50.0); // User tries to set explicit limits

      final bounds = BoundsCalculator.calculateBounds(
          values, explicitLimits, notApplicableGeometries);

      // Should ignore explicit limits and return ignored bounds
      expect(bounds.min, equals(0.0));
      expect(bounds.max, equals(0.0));
    });

    test('ignored bounds have highest precedence over empty values', () {
      final emptyValues = <double>[];
      final notApplicableGeometries = [TestNotApplicableGeometry()];

      final bounds = BoundsCalculator.calculateBounds(
          emptyValues, null, notApplicableGeometries);

      // Should ignore empty values fallback and return ignored bounds
      expect(bounds.min, equals(0.0));
      expect(bounds.max, equals(0.0));
    });
  });

  group('limit validation', () {
    test('accepts equal limits (min == max)', () {
      final values = [10.0, 20.0, 30.0];
      final limits = (15.0, 15.0); // Equal limits
      final geometries = [TestDataDrivenGeometry()];

      final bounds =
          BoundsCalculator.calculateBounds(values, limits, geometries);

      // Should return valid bounds with min and max both equal to specified value
      expect(bounds.min, equals(15.0));
      expect(bounds.max, equals(15.0));
    });

    test('throws ArgumentError for inverted limits (min > max)', () {
      final values = [10.0, 20.0, 30.0];
      final limits = (50.0, 20.0); // Inverted limits: min > max
      final geometries = [TestDataDrivenGeometry()];

      // Should throw ArgumentError with specific message
      expect(
        () => BoundsCalculator.calculateBounds(values, limits, geometries),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            equals(
                'Specified limits were inverted: min (50.0) > max (20.0). Min must be less than or equal to max.'),
          ),
        ),
      );
    });
  });
}
