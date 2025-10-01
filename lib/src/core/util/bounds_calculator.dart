import 'dart:math' as math;

import '../geometry.dart';

/// Enum for axis bounds calculation behaviors with options as follows.
///
/// - `nonApplicable`: In BoundsCalculator, returns sentinel value for ignored bounds
/// as highest precedence (`Bounds.ignored()` of `(min, max) = (0, 0)`) for charts
/// (e.g., pie charts) that don't use continuous axes.
///
/// Other options define fallback behavior when bounds are not explicitly specified
/// in the grammar of graphics:
///
/// - `zeroBaseline`: Charts start from zero. For quantity comparison charts
/// (e.g., bars, area).
/// - `dataDriven`: Tight range around actual data (min, max) with minimal
/// padding. For trend analysis charts (lines, points, bubbles, heat maps).

enum BoundsBehavior {
  zeroBaseline,
  dataDriven,
  notApplicable,
}

/// Represents axis bounds with minimum and maximum values.
class Bounds {
  final double min;
  final double max;

  const Bounds(this.min, this.max);

  /// Creates bounds that indicate the `min, max` values are ignored.
  ///
  /// Used for chart types that don't use continuous X/Y axes (e.g., pie charts).
  const Bounds.ignored()
      : min = 0,
        max = 0;
}

/// Utility class for calculating axis bounds based on data and geometry behavior.
class BoundsCalculator {
  /// Calculate bounds based on limits tuple and bounds behavior context.
  ///
  /// Each geometry defines its own bounds behavior, one of the `BoundsBehavior` enum,
  /// that serves either as (a) a fallback when bounds aren't explicitly specified in
  /// the grammar of graphics or (b) triggers, with highest precedence, a `Bounds.ignored()`
  /// sentinel of `(0, 0)` min/max tuple when one of the [geometries] list specifies
  /// `BoundsBehavior.notApplicable` (e.g., for pie charts).
  ///
  /// Otherwise, any explicit min/max bound overrides the other behavior fallbacks:
  ///
  /// - `zeroBaseline`: Charts start from zero. For quantity comparison charts
  /// (e.g., bars, area).
  /// - `dataDriven`: Tight range around actual data (min, max) with minimal
  /// padding. For trend analysis charts (lines, points, bubbles, heat maps).
  ///
  /// Precedence order:
  ///
  /// 1. Ignored bounds (highest priority - e.g., pie charts don't use continuous axes
  /// regardless of user input)
  /// 2. Explicit `limits` tuple (when bounds are applicable)
  /// 3. Geometry-set bounds behavior fallback (when limits not fully specified)
  ///
  /// Parameters:
  /// - [values]: The data values to calculate bounds for, based on the data range.
  /// - [limits]: Optional tuple specifying `(min, max)` bounds. Null value(s) use `BoundsBehavior` fallback.
  /// - [geometries]: List of chart geometries defining `BoundsBehavior` fallbacks for the [values] set.
  /// - [applyPadding]: Whether to apply padding to calculated bounds. Defaults to true.
  ///
  /// Returns Bounds object with min and max values.
  ///
  /// Examples:
  /// ```dart
  /// // Ignored bounds (highest priority) - pie charts don't use continuous axes
  /// final bounds0 = BoundsCalculator.calculateBounds([10, 20, 30], (5, 100), [PieGeometry()]);
  /// assert(bounds0.min == 0 && bounds0.max == 0); // Equivalent to Bounds.ignored()
  ///
  /// // Full bounds specification (next highest priority)
  /// final bounds1 = BoundsCalculator.calculateBounds(values, (0, 100), geometries);
  ///
  /// // Partial bounds specification (mix explicit + behavior fallback)
  /// final bounds2 = BoundsCalculator.calculateBounds(values, (0, null), geometries);
  /// final bounds3 = BoundsCalculator.calculateBounds(values, (null, 100), geometries);
  ///
  /// // Pure geometry behavior fallback
  /// final bounds4 = BoundsCalculator.calculateBounds(values, null, geometries);
  /// ```
  static Bounds calculateBounds(
    List<double> values,
    (double?, double?)? limits,
    List<Geometry> geometries, {
    bool applyPadding = true,
  }) {
    // Check for ignored bounds first as highest precedence: if any geometry doesn't use
    // continuous axes, ignore all bounds regardless of user input.
    final behaviors = geometries.map((g) => g.getBoundsBehavior()).toSet();
    if (behaviors.contains(BoundsBehavior.notApplicable)) {
      return const Bounds.ignored();
    }

    // If limits are fully specified, use them directly (even if values.isEmpty)
    if (limits != null && limits.$1 != null && limits.$2 != null) {
      return Bounds(limits.$1!, limits.$2!);
    }

    // Handle empty values with partial or no limits
    if (values.isEmpty) {
      return Bounds(limits?.$1 ?? 0, limits?.$2 ?? 1);
    }

    // Calculate data-driven bounds
    final dataMin = values.reduce(math.min);
    final dataMax = values.reduce(math.max);

    // Apply geometry behavior fallbacks when limits not fully specified
    final behaviorFallbacks =
        _getGeometryAwareDefaults(dataMin, dataMax, geometries, applyPadding);

    // Use min XOR max limits if specified, otherwise use respective geometry behavior fallbacks
    final finalMin = limits?.$1 ?? behaviorFallbacks.min;
    final finalMax = limits?.$2 ?? behaviorFallbacks.max;

    return Bounds(finalMin, finalMax);
  }

  /// Get geometry-aware default bounds using BoundsBehavior specification exposed by geometry.
  ///
  /// Each geometry defines its own BoundsBehavior through getBoundsBehavior().
  /// This defines the fallback behavior when bounds aren't explicitly specified
  /// in the grammar of graphics based on options selected from the BoundsBehavior enum:
  /// - BoundsBehavior.zeroBaseline: Zero baseline for quantity comparison (bars, areas)
  /// - BoundsBehavior.dataDriven: Data-driven bounds for trend analysis (lines, points, bubbles, heat maps)
  ///
  /// Note that `BoundsBehavior.notApplicable`, for charts that don't use continuous axes (e.g., pie charts),
  /// returns `Bounds.ignored()` in main logic of `calculateBounds()` as the absolute highest precedence.
  ///
  /// Precedence order when multiple geometries are present:
  /// 1. Zero baseline behaviors (for mixed chart types with bars/areas)
  /// 2. Data-driven behaviors
  static Bounds _getGeometryAwareDefaults(
    double dataMin,
    double dataMax,
    List<Geometry> geometries,
    bool applyPadding,
  ) {
    // Collect behaviors from all geometries
    final behaviors = geometries.map((g) => g.getBoundsBehavior()).toSet();

    // Assert that notApplicable behaviors should never reach this method
    // They are handled at highest precedence in calculateBounds()
    if (behaviors.contains(BoundsBehavior.notApplicable)) {
      throw StateError(
          'BoundsBehavior.notApplicable should be handled in calculateBounds() '
          'before reaching _getGeometryAwareDefaults(). Its presence in this method '
          'indicates a logic error.');
    }

    if (dataMin == dataMax) {
      // Handle single-value case - behavior depends on applyPadding parameter
      if (!applyPadding) {
        // No padding - use exact single value as both min and max
        return Bounds(dataMin, dataMax);
      }

      // Apply padding for single value case
      if (dataMin == 0) return const Bounds(-0.5, 0.5);
      final padding = dataMin.abs() * 0.1;
      return Bounds(dataMin - padding, dataMax + padding);
    }

    // Prioritize zero baseline for mixed charts (e.g., bar + line combo)
    if (behaviors.contains(BoundsBehavior.zeroBaseline)) {
      return _calculateZeroBaseline(dataMin, dataMax, applyPadding);
    }

    // Look for data-driven bounds next
    if (behaviors.contains(BoundsBehavior.dataDriven)) {
      return _calculateDataDriven(dataMin, dataMax, applyPadding);
    }

    // Default to data-driven bounds for unknown behaviors
    return _calculateDataDriven(dataMin, dataMax, applyPadding);
  }

  /// Calculate zero-baseline bounds for quantity comparison charts (e.g., bars, areas).
  ///
  /// This behavior ensures that bars and areas grow from a zero baseline as a sensible, meaningful
  /// default to compare quantities visually.
  static Bounds _calculateZeroBaseline(
      double dataMin, double dataMax, bool applyPadding) {
    if (!applyPadding) {
      // No padding - use exact data bounds with zero baseline
      if (dataMax <= 0) {
        return Bounds(dataMin, 0);
      } else if (dataMin >= 0) {
        return Bounds(0, dataMax);
      } else {
        return Bounds(dataMin, dataMax);
      }
    }

    // Apply 10% padding when applyPadding is true
    if (dataMax <= 0) {
      // All negative data - zero upper bound
      return Bounds(dataMin * 1.1, 0);
    } else if (dataMin >= 0) {
      // All positive data - zero lower bound
      return Bounds(0, dataMax * 1.1);
    } else {
      // Mixed positive/negative data - include zero
      return Bounds(dataMin * 1.1, dataMax * 1.1);
    }
  }

  /// Calculate data-driven bounds for trend analysis charts (lines, points, bubbles, heat maps).
  ///
  /// This default behavior focuses bounds around the actual data range with minimal padding,
  /// providing better resolution for trend analysis and pattern recognition.
  static Bounds _calculateDataDriven(
      double dataMin, double dataMax, bool applyPadding) {
    if (!applyPadding) {
      // No padding - use exact data bounds
      return Bounds(dataMin, dataMax);
    }

    // Apply 5% padding when applyPadding is true
    final padding = (dataMax - dataMin) * 0.05; // 5% padding across range
    return Bounds(dataMin - padding, dataMax + padding);
  }
}
