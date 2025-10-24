import 'dart:math' as math;

/// Implementation of the Wilkinson Extended Algorithm for positioning tick labels.
/// Based on: Justin Talbot, Sharon Lin, Pat Hanrahan, "An Extension of Wilkinson's Algorithm
/// for Positioning Tick Labels on Axes," *IEEE Trans. Visualization & Comp. Graphics (Proc. InfoVis)*,
/// 2010, http://vis.stanford.edu/papers/tick-labels.
///
/// This algorithm generates "nice" tick labels by optimizing three criteria:
/// - Simplicity: Prefer simple step sizes (1, 5, 2, 2.5, etc.)
/// - Coverage: Minimize whitespace beyond data range
/// - Density: Match target number of ticks
///
/// A fourth criterion, "legibility", would avoid overlapping labels and is left for future enhancement.
class WilkinsonLabeling {
  /// Base nice numbers in order of preference
  static const Q = [1.0, 5.0, 2.0, 2.5, 4.0, 3.0];

  /// Scoring weights: [simplicity, coverage, density, legibility]
  static const weights = [0.2, 0.25, 0.5, 0.05];

  /// Main entry point - returns nice tick values for the given data range
  ///
  /// Parameters:
  /// - dmin, dmax: Data range
  /// - screenLength: Length of axis in pixels (for density calculation)
  /// - targetDensity: Desired density of labels per pixel
  /// - limits: Optional hard constraints (minLimit, maxLimit) that ticks must not exceed
  ///
  /// Returns: List of nice tick values
  static List<double> extended(
      double dmin, double dmax, double screenLength, double targetDensity,
      {(double?, double?)? limits, bool simpleLinear = false}) {
    // Handle edge cases
    if (dmin == dmax) {
      return [dmin];
    }
    if (dmin > dmax) {
      final temp = dmin;
      dmin = dmax;
      dmax = temp;
    }

    List<double> makeLinearTicks() {
      // Estimate a reasonable count from screen length and target density
      final estimatedCount =
          (targetDensity * screenLength).round().clamp(2, 10);
      return _fallbackTicks(dmin, dmax, estimatedCount, limits);
    }

    if (simpleLinear) {
      return makeLinearTicks();
    }

    double bestScore = -2.0;
    double? bestLMin, bestLMax, bestStep;

    // Search through nice numbers and step configurations
    for (int qIndex = 0; qIndex < Q.length; qIndex++) {
      final q = Q[qIndex];

      // Try different skip amounts (j)
      for (int j = 1; j <= 10; j++) {
        final simplicityMax = _simplicityMax(qIndex, j);

        // Prune: if best possible simplicity can't beat current best, skip
        if (_score([simplicityMax, 1.0, 1.0, 1.0]) < bestScore) {
          break;
        }

        // Try different numbers of ticks (search up to 20 labels)
        for (int k = 2; k <= 20; k++) {
          final densityMax = _densityMax(k, screenLength, targetDensity);

          // Prune: if best possible simplicity+density can't beat current best, skip
          if (_score([simplicityMax, 1.0, densityMax, 1.0]) < bestScore) {
            break;
          }

          // Calculate the rough step size
          final delta = (dmax - dmin) / (k + 1) / (j * q);
          final z = math.log(delta) / math.ln10;

          // Skip if z is not finite
          if (!z.isFinite) continue;

          // Try different powers of 10
          for (int zVal = z.ceil(); zVal <= z.ceil() + 3; zVal++) {
            final step = j * q * math.pow(10, zVal);

            // Skip if step is not finite or results in problematic calculations
            if (!step.isFinite || step == 0) continue;

            final coverageMax = _coverageMax(dmin, dmax, step * (k - 1));

            // Prune: if best possible score can't beat current best, skip
            if (_score([simplicityMax, coverageMax, densityMax, 1.0]) <
                bestScore) {
              break;
            }

            // Try different starting points
            final dmaxOverStep = dmax / step;
            final dminOverStep = dmin / step;

            // Skip if division results in infinity or NaN
            if (!dmaxOverStep.isFinite || !dminOverStep.isFinite) continue;

            final minStart = dmaxOverStep.floor() - (k - 1);
            final maxStart = dminOverStep.ceil();

            for (double start = minStart.toDouble();
                start <= maxStart;
                start += 1.0) {
              final lmin = start * step;
              final lmax = lmin + step * (k - 1);

              // Skip if ticks violate hard limits
              if (limits != null) {
                final (minLimit, maxLimit) = limits;
                if (minLimit != null && lmin < minLimit) continue;
                if (maxLimit != null && lmax > maxLimit) continue;
              }

              // Calculate actual scores
              final s = _simplicity(qIndex, j, lmin, lmax, dmin, dmax);
              final c = _coverage(dmin, dmax, lmin, lmax);
              final d = _density(k, screenLength, targetDensity);
              final l = _legibility(); // Always 1.0 for now

              final score = _score([s, c, d, l]);

              if (score > bestScore) {
                bestScore = score;
                bestLMin = lmin;
                bestLMax = lmax;
                bestStep = step;
              }
            }
          }
        }
      }
    }

    // Generate ticks from best labeling found
    if (bestLMin != null && bestLMax != null && bestStep != null) {
      final ticks = <double>[];
      double tick = bestLMin;
      while (tick <= bestLMax + bestStep * 0.0001) {
        // Small epsilon for floating point
        ticks.add(_cleanNumber(tick));
        tick += bestStep;
      }
      return ticks;
    }

    // Fallback: if search failed, return simple linear ticks
    return makeLinearTicks();
  }

  /// Calculate simplicity score
  /// Prefers earlier elements in Q, lower skip amounts, and including zero
  static double _simplicity(
      int qIndex, int j, double lmin, double lmax, double dmin, double dmax) {
    final v = (lmin <= 0 && lmax >= 0) ? 1.0 : 0.0; // Bonus for including 0
    final i = qIndex + 1; // 1-indexed
    return 1.0 - (i - 1) / (Q.length - 1) - j + v;
  }

  /// Maximum possible simplicity (used for pruning)
  static double _simplicityMax(int qIndex, int j) {
    final i = qIndex + 1;
    return 1.0 - (i - 1) / (Q.length - 1) - j + 1.0;
  }

  /// Calculate coverage score. The algorithm penalizes whitespace beyond data range
  static double _coverage(double dmin, double dmax, double lmin, double lmax) {
    final dataRange = dmax - dmin;
    if (dataRange == 0) return 1.0;

    final leftError = (dmin - lmin).abs();
    final rightError = (dmax - lmax).abs();

    // Normalize by 10% of data range (Wilkinson's recommendation)
    final normalizer = 0.1 * dataRange;
    return 1.0 -
        0.5 *
            (leftError * leftError + rightError * rightError) /
            (normalizer * normalizer);
  }

  /// Maximum possible coverage (used for pruning)
  static double _coverageMax(double dmin, double dmax, double span) {
    final dataRange = dmax - dmin;
    if (span > dataRange) {
      final excess = span - dataRange;
      final normalizer = 0.1 * dataRange;
      return 1.0 - 0.5 * (excess * excess) / (normalizer * normalizer);
    }
    return 1.0;
  }

  /// Calculate density score per Talbot/Lin/Hanrahan (2010)
  /// Uses labels per screen pixel: density = 2 - max(ρ/ρₜ, ρₜ/ρ)
  ///
  /// Note: The published paper states "1 - max(...)" in Section 4.3, but this
  /// appears to be a typo. The reference R implementation by the paper's authors
  /// uses "2 - max(...)", which is necessary for perfect density (ρ = ρₜ) to
  /// score 1.0 as stated in the paper's optimization bounds.
  /// Reference: https://rdrr.io/cran/labeling/src/R/labeling.R
  static double _density(int k, double screenLength, double targetDensity) {
    if (screenLength == 0 || targetDensity == 0) return 0.0;

    // Actual density = labels per pixel
    final actualDensity = k / screenLength;

    // Correct formula: 2 - max(ρ/ρₜ, ρₜ/ρ)
    // Treats over-density and under-density symmetrically
    final ratio1 = actualDensity / targetDensity;
    final ratio2 = targetDensity / actualDensity;
    return 2.0 - math.max(ratio1, ratio2);
  }

  /// Maximum possible density (used for pruning)
  /// Returns best achievable density score for this k value
  static double _densityMax(int k, double screenLength, double targetDensity) {
    return _density(k, screenLength, targetDensity);
  }

  /// Calculate legibility score
  /// For now, always returns 1.0 (future: font size, orientation optimization)
  static double _legibility() {
    return 1.0;
  }

  /// Calculate weighted score from component scores
  static double _score(List<double> scores) {
    assert(scores.length == weights.length,
        'scores.length must match weights.length (${weights.length})');
    double total = 0.0;
    for (int i = 0; i < scores.length; i++) {
      total += weights[i] * scores[i];
    }
    return total;
  }

  /// Clean up floating point artifacts
  static double _cleanNumber(double value) {
    // Round to 10 decimal places to eliminate floating point errors
    final rounded = (value * 1e10).roundToDouble() / 1e10;

    // If very close to an integer, return the integer
    if ((rounded - rounded.round()).abs() < 1e-10) {
      return rounded.roundToDouble();
    }

    return rounded;
  }

  /// Fallback tick generation if search fails
  static List<double> _fallbackTicks(
      double dmin, double dmax, int count, (double?, double?)? limits) {
    // Constrain to limits, if provided
    final constrainedMin =
        limits?.$1 != null && limits!.$1! > dmin ? limits.$1! : dmin;
    final constrainedMax =
        limits?.$2 != null && limits!.$2! < dmax ? limits.$2! : dmax;

    if (count <= 1) return [constrainedMin];
    final step = (constrainedMax - constrainedMin) / (count - 1);
    return List.generate(count, (i) => constrainedMin + i * step);
  }
}
