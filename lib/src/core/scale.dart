import 'package:flutter/material.dart';

import 'geometry.dart';
import 'label_formatter.dart';
import 'util/bounds_calculator.dart';
import 'util/wilkinson_labeling.dart';

/// Base class for all scales
abstract class Scale {
  final LabelFormatter _formatter;

  /// Default range for scales. Numeric for all scale types
  List<double> _range = [0, 1];

  /// Optional limits for this scale - used when setBounds is called with null limits
  (double?, double?)? limits;

  /// Optional title for this scale (e.g., "Revenue (USD)", "Temperature (°C)")
  final String? title;

  /// Optimal pixels per axis label for readability
  /// Could be threaded as a parameter into API if users demand it
  static const double optimalPixelsPerLabel = 60.0;

  Scale({LabelCallback? labelFormatter, this.limits, this.title})
      : _formatter = LabelFormatter(labelFormatter);

  /// Return display parameter within range from value on domain.
  dynamic scale(dynamic value);
  List<dynamic>
      get domain; // Abstract - each scale implements its own domain type

  /// Map any value to 0-1 position within domain.
  ///
  /// This method applies only to continuous (numeric) domains. While OrdinalScale
  /// inherits this method, it should not invoke it. Ordinal scales use indexOf
  /// for positioning instead.
  double normalize(dynamic value, {bool clamp = true}) {
    final numericDomain = domain.cast<double>();
    final domainSpan = numericDomain[1] - numericDomain[0];
    if (domainSpan == 0) return 0.0;
    final numValue = (value is num) ? value.toDouble() : 0.0;
    final result = (numValue - numericDomain[0]) / domainSpan;
    return clamp ? result.clamp(0.0, 1.0) : result;
  }

  /// Map a 0-1 normalized value to range.
  double scaleToRange(double normalized) {
    final rangeSpan = range[1] - range[0];
    return range[0] + normalized * rangeSpan;
  }

  /// Unified range implementation for all scales
  List<double> get range => _range;
  set range(List<double> value) => _range = List.from(value);

  /// Inverse transformation: convert screen coordinate back to data value.
  /// This default implementation is for linear scales.
  dynamic invert(double screenValue) {
    final numericDomain = domain.cast<double>();
    final rangeSpan = range[1] - range[0];
    final domainSpan = numericDomain[1] - numericDomain[0];
    if (rangeSpan == 0) return numericDomain[0];
    return numericDomain[0] + (screenValue - range[0]) / rangeSpan * domainSpan;
  }

  /// Get tick values for axis display
  List<dynamic> getTicks();

  /// Format a value for display using this Scale instance's label formatter
  String formatLabel(dynamic value) => _formatter.format(value);

  /// Set bounds for this scale given data values, limits, and geometry context.
  /// Uses passed limits, or falls back to scale's own limits, or geometry behavior.
  void setBounds(List<double> values, (double?, double?)? passedLimits,
      List<Geometry> geometries) {
    final effectiveLimits = passedLimits ?? limits;
    setBoundsInternal(values, effectiveLimits, geometries);
  }

  /// Internal bounds setting - each scale implements its own logic.
  void setBoundsInternal(List<double> values,
      (double?, double?)? effectiveLimits, List<Geometry> geometries);
}

/// Linear scale for continuous data
class LinearScale extends Scale {
  List<double> _domain = [0, 1];
  List<double>? _ticks; // Cached ticks from Wilkinson algorithm

  LinearScale({super.limits, super.labelFormatter, super.title});

  @override
  List<double> get domain => _domain;
  set domain(List<double> value) => _domain = List.from(value);

  @override
  double scale(dynamic value) {
    // normalize, but do not clamp any values out of bounds
    return scaleToRange(normalize(value, clamp: false));
  }

  @override
  // Return cached ticks computed during setBoundsInternal()
  // As long as range is set BEFORE setBounds(), cache is always valid
  List<dynamic> getTicks() {
    return _ticks ?? [];
  }

  @override
  void setBoundsInternal(List<double> values,
      (double?, double?)? effectiveLimits, List<Geometry> geometries) {
    final bounds = BoundsCalculator.calculateBounds(
        values, effectiveLimits, geometries,
        applyPadding: true);

    if (bounds != const Bounds.ignored()) {
      // Use Wilkinson algorithm to extend bounds to nice round numbers
      final screenLength = (range[1] - range[0]).abs();

      // Guard against zero or negative range during layout/bootstrap
      if (screenLength <= 0) {
        _ticks = null;
        _domain = [bounds.min, bounds.max];
        return;
      }

      final targetLabelCount =
          (screenLength / Scale.optimalPixelsPerLabel).round();
      final targetDensity = targetLabelCount / screenLength; // labels per pixel

      final niceTicks = WilkinsonLabeling.extended(
          bounds.min, bounds.max, screenLength, targetDensity,
          limits: effectiveLimits);

      if (niceTicks.isNotEmpty) {
        // Cache ticks for getTicks() to avoid recomputing
        _ticks = niceTicks;

        // Ensure domain covers the actual data range
        // Use nice ticks if they cover the data, otherwise expand to ensure coverage
        final niceMin =
            niceTicks.first <= bounds.min ? niceTicks.first : bounds.min;
        final niceMax =
            niceTicks.last >= bounds.max ? niceTicks.last : bounds.max;
        _domain = [niceMin, niceMax];
      } else {
        _ticks = null;
        _domain = [bounds.min, bounds.max];
      }
    }
  }
}

/// Ordinal scale for categorical data (essential for bar charts)
class OrdinalScale extends Scale {
  List<dynamic> _domain = [];
  final double _padding; // 10% padding between bands
  double _bandWidth = 0;

  OrdinalScale({double padding = 0.1, super.labelFormatter, super.title})
      : _padding = padding;

  @override
  List<dynamic> get domain => _domain;
  set domain(List<dynamic> value) {
    _domain = List.from(value);
    _calculateBandWidth();
  }

  @override
  set range(List<double> value) {
    _range = List.from(value);
    _calculateBandWidth();
  }

  double get bandWidth => _bandWidth;
  double get padding => _padding;

  void _calculateBandWidth() {
    if (_domain.isEmpty) {
      _bandWidth = 0;
      return;
    }

    final totalRange = _range[1] - _range[0];
    final totalPadding = _padding * totalRange;
    final availableSpace = totalRange - totalPadding;
    _bandWidth = availableSpace / _domain.length;
  }

  @override
  double scale(dynamic value) {
    final index = _domain.indexOf(value);
    if (index == -1) return _range[0];

    final totalRange = _range[1] - _range[0];
    final paddingSpace = _padding * totalRange / 2; // Split padding

    return _range[0] +
        paddingSpace +
        index * (_bandWidth + _padding * totalRange / _domain.length);
  }

  /// Get the center position of a band
  double bandCenter(dynamic value) {
    return scale(value) + _bandWidth / 2;
  }

  @override
  // For ordinal scales, return all domain values or subset
  List<dynamic> getTicks() {
    if (_domain.isEmpty) return [];

    final screenLength = (_range[1] - _range[0]).abs();

    // Handle edge case: zero-size screen (e.g., during initialization)
    if (screenLength == 0) return List.from(_domain);

    final targetLabelCount = (screenLength / Scale.optimalPixelsPerLabel)
        .round()
        .clamp(1, _domain.length);

    // If we have fewer categories than target, show all
    if (_domain.length <= targetLabelCount) {
      return List.from(_domain);
    }

    // Otherwise, intelligently subset by showing every nth category
    // We know _domain.length > targetLabelCount, so step >= 2
    final step = (_domain.length / targetLabelCount).ceil();
    final count = (_domain.length / step).ceil();
    final result = List.generate(count, (i) => _domain[(i * step)]);

    // Always include the last domain entry if not already present
    if (result.last != _domain.last) {
      result.add(_domain.last);
    }
    return result;
  }

  /// Convert screen coordinate back to category value
  @override
  dynamic invert(double screenValue) {
    if (_domain.isEmpty) return null;

    final totalRange = _range[1] - _range[0];
    final paddingSpace = _padding * totalRange / 2;
    final effectiveValue = screenValue - _range[0] - paddingSpace;

    if (effectiveValue < 0) return _domain.first;

    final bandWithPadding = _bandWidth + _padding * totalRange / _domain.length;
    final index = (effectiveValue / bandWithPadding).floor();

    if (index >= _domain.length) return _domain.last;
    return _domain[index];
  }

  @override
  void setBoundsInternal(List<double> values,
      (double?, double?)? effectiveLimits, List<Geometry> geometries) {
    // Ordinal scales don't use continuous bounds - so this is a no-op
  }
}

/// Color scale for categorical or continuous color mapping
class ColorScale {
  final List<dynamic> values;
  final List<Color> colors;
  final Map<dynamic, Gradient>? gradients;

  ColorScale({
    this.values = const [],
    this.colors = const [],
    this.gradients,
  });

  /// Returns either a Color or Gradient for the given value
  dynamic scale(dynamic value) {
    // Check gradients first - this allows gradient-only mappings
    if (gradients != null && gradients!.containsKey(value)) {
      return gradients![value]!;
    }

    // Fall back to solid colors if available
    if (values.isEmpty || colors.isEmpty) return Colors.blue;

    final index = values.indexOf(value);
    return index >= 0 ? colors[index % colors.length] : colors[0];
  }

  /// Returns true if this value has a gradient
  bool hasGradient(dynamic value) {
    return gradients != null && gradients!.containsKey(value);
  }
}

/// Size scale for point size mapping
class SizeScale extends Scale {
  List<double> _domain;

  SizeScale({
    List<double> domain = const [0, 1],
    List<double> range = const [3, 10],
    super.limits,
    super.labelFormatter,
    super.title,
  }) : _domain = List.from(domain) {
    this.range = range; // Use setter to trigger validation
  }

  @override
  List<double> get domain => _domain;
  set domain(List<double> value) => _domain = List.from(value);

  @override
  set range(List<double> value) {
    if (value[0] < 0 || value[1] < 0) {
      throw ArgumentError(
        'SizeScale range values must be non-negative. '
        'Got range: [${value[0]}, ${value[1]}]',
      );
    }
    super.range = value;
  }

  @override
  double scale(dynamic value) {
    // normalize, but do not clamp any values out of bounds
    return scaleToRange(normalize(value, clamp: false));
  }

  @override
  List<dynamic> getTicks() {
    // Size scales do not use axes w/ tick marks
    return [];
  }

  @override
  void setBoundsInternal(List<double> values,
      (double?, double?)? effectiveLimits, List<Geometry> geometries) {
    if (values.isEmpty) {
      _domain = [0, 1];
      return;
    }

    // For size scales, we want exact data bounds without padding
    final bounds = BoundsCalculator.calculateBounds(
        values, effectiveLimits, geometries,
        applyPadding: false);

    if (bounds != const Bounds.ignored()) {
      _domain = [bounds.min, bounds.max];
    }
  }
}

/// Gradient color scale for continuous color mapping (e.g., heat maps)
class GradientColorScale extends Scale {
  List<double> _domain;
  final List<Color> colors;
  final bool interpolate;

  GradientColorScale({
    List<double> domain = const [0, 1],
    this.colors = const [Colors.blue, Colors.red],
    this.interpolate = true,
    super.limits,
    super.labelFormatter,
    super.title,
  }) : _domain = List.from(domain);

  @override
  List<double> get domain => _domain;
  set domain(List<double> value) => _domain = List.from(value);

  @override
  List<double> get range =>
      [0, 1]; // Gradient color scales always use 0, 1 range

  @override
  Color scale(dynamic value) {
    if (colors.isEmpty) return Colors.grey;
    if (colors.length == 1) return colors[0];

    // Normalize to get 0-1 value (clamped)
    final normalizedValue = normalize(value);

    if (!interpolate) {
      // Discrete colors based on segments
      final colorIndex = (normalizedValue * (colors.length - 1)).round();
      return colors[colorIndex.clamp(0, colors.length - 1)];
    }

    // Interpolate between colors
    final scaledValue = normalizedValue * (colors.length - 1);
    final lowerIndex = scaledValue.floor();
    final upperIndex = scaledValue.ceil();

    if (lowerIndex == upperIndex) {
      return colors[lowerIndex];
    }

    final t = scaledValue - lowerIndex;
    return Color.lerp(colors[lowerIndex], colors[upperIndex], t)!;
  }

  @override
  double invert(double screenValue) {
    // Not applicable for color scale
    return 0;
  }

  @override
  List<dynamic> getTicks() {
    // Gradient color scales do not use axes w/ tick marks
    return [];
  }

  @override
  void setBoundsInternal(List<double> values,
      (double?, double?)? effectiveLimits, List<Geometry> geometries) {
    final bounds =
        BoundsCalculator.calculateBounds(values, effectiveLimits, geometries);

    if (bounds != const Bounds.ignored()) {
      _domain = [bounds.min, bounds.max];
    }
  }

  /// Predefined gradient themes
  static GradientColorScale viridis() {
    return GradientColorScale(
      colors: [
        const Color(0xFF440154), // Dark purple
        const Color(0xFF3B528B), // Blue
        const Color(0xFF21908C), // Teal
        const Color(0xFF5DC863), // Green
        const Color(0xFFFDE725), // Yellow
      ],
    );
  }

  static GradientColorScale coolWarm() {
    return GradientColorScale(
      colors: [
        const Color(0xFF3B4CC0), // Cool blue
        const Color(0xFF7396F5), // Light blue
        const Color(0xFFDDDDDD), // Neutral gray
        const Color(0xFFF7AA8F), // Light red
        const Color(0xFFB40426), // Warm red
      ],
    );
  }

  static GradientColorScale heatMap() {
    return GradientColorScale(
      colors: [
        const Color(0xFF000033), // Dark blue
        const Color(0xFF000099), // Blue
        const Color(0xFF0000FF), // Bright blue
        const Color(0xFF00FFFF), // Cyan
        const Color(0xFF00FF00), // Green
        const Color(0xFFFFFF00), // Yellow
        const Color(0xFFFF8800), // Orange
        const Color(0xFFFF0000), // Red
        const Color(0xFF880000), // Dark red
      ],
    );
  }

  static GradientColorScale greenRed() {
    return GradientColorScale(
      colors: [
        const Color(0xFF00CC00), // Green
        const Color(0xFF99FF99), // Light green
        const Color(0xFFFFFFFF), // White
        const Color(0xFFFF9999), // Light red
        const Color(0xFFCC0000), // Red
      ],
    );
  }
}
