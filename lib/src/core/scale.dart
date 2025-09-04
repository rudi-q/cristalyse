import 'package:flutter/material.dart';

import 'label_formatter.dart';

/// Base class for all scales
abstract class Scale {
  final LabelFormatter _formatter;

  Scale({LabelCallback? labelFormatter})
      : _formatter = LabelFormatter(labelFormatter);

  double scale(dynamic value);
  List<dynamic> getTicks(int count);
  List<dynamic> get domain;
  List<double> get range;

  /// Inverse transformation: convert screen coordinate back to data value
  dynamic invert(double screenValue);

  /// Format a value for display using this Scale instance's label formatter
  String formatLabel(dynamic value) => _formatter.format(value);
}

/// Linear scale for continuous data
class LinearScale extends Scale {
  List<double> _domain = [0, 1];
  List<double> _range = [0, 1];
  final double? min;
  final double? max;

  LinearScale({this.min, this.max, super.labelFormatter});

  @override
  List<double> get domain => _domain;
  set domain(List<double> value) => _domain = value;

  @override
  List<double> get range => _range;
  set range(List<double> value) => _range = value;

  @override
  double scale(dynamic value) {
    if (value is! num) return _range[0];
    final numValue = value.toDouble();
    final domainSpan = _domain[1] - _domain[0];
    final rangeSpan = _range[1] - _range[0];
    if (domainSpan == 0) return _range[0];
    return _range[0] + (numValue - _domain[0]) / domainSpan * rangeSpan;
  }

  @override
  List<double> getTicks(int count) {
    if (count <= 1) return [_domain[0]];
    final step = (_domain[1] - _domain[0]) / (count - 1);
    return List.generate(count, (i) => _domain[0] + i * step);
  }

  /// Convert screen coordinate back to data value
  @override
  double invert(double screenValue) {
    final rangeSpan = _range[1] - _range[0];
    final domainSpan = _domain[1] - _domain[0];
    if (rangeSpan == 0) return _domain[0];
    return _domain[0] + (screenValue - _range[0]) / rangeSpan * domainSpan;
  }
}

/// Ordinal scale for categorical data (essential for bar charts)
class OrdinalScale extends Scale {
  List<dynamic> _domain = [];
  List<double> _range = [0, 1];
  final double _padding; // 10% padding between bands
  double _bandWidth = 0;

  OrdinalScale({double padding = 0.1, super.labelFormatter})
      : _padding = padding;

  @override
  List<dynamic> get domain => _domain;
  set domain(List<dynamic> value) {
    _domain = value;
    _calculateBandWidth();
  }

  @override
  List<double> get range => _range;
  set range(List<double> value) {
    _range = value;
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
  List<dynamic> getTicks(int count) {
    // For ordinal scales, return all domain values or subset
    if (count >= _domain.length) return List.from(_domain);

    final step = _domain.length / count;
    return List.generate(count, (i) => _domain[(i * step).floor()]);
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
    if (values.isEmpty || colors.isEmpty) return Colors.blue;

    // Check if we have a gradient for this specific value
    if (gradients != null && gradients!.containsKey(value)) {
      return gradients![value]!;
    }

    // Fall back to solid color
    final index = values.indexOf(value);
    return index >= 0 ? colors[index % colors.length] : colors[0];
  }

  /// Returns true if this value has a gradient
  bool hasGradient(dynamic value) {
    return gradients != null && gradients!.containsKey(value);
  }
}

/// Size scale for point size mapping
class SizeScale {
  final List<double> domain;
  final List<double> range;

  SizeScale({this.domain = const [0, 1], this.range = const [3, 10]});

  double scale(double value) {
    final domainSpan = domain[1] - domain[0];
    final rangeSpan = range[1] - range[0];
    if (domainSpan == 0) return range[0];
    return range[0] + (value - domain[0]) / domainSpan * rangeSpan;
  }
}

/// Gradient color scale for continuous color mapping (e.g., heat maps)
class GradientColorScale {
  final List<double> domain;
  final List<Color> colors;
  final bool interpolate;

  GradientColorScale({
    this.domain = const [0, 1],
    this.colors = const [Colors.blue, Colors.red],
    this.interpolate = true,
  });

  Color scale(double value) {
    if (colors.isEmpty) return Colors.grey;
    if (colors.length == 1) return colors[0];

    // Normalize value to 0-1 range
    final minDomain = domain.isNotEmpty ? domain.first : 0;
    final maxDomain = domain.length > 1 ? domain.last : 1;
    final normalizedValue = maxDomain > minDomain
        ? ((value - minDomain) / (maxDomain - minDomain)).clamp(0.0, 1.0)
        : 0.0;

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
