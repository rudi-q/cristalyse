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

  LinearScale({this.min, this.max, LabelCallback? labelFormatter})
      : super(labelFormatter: labelFormatter);

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

  OrdinalScale({double padding = 0.1, LabelCallback? labelFormatter})
      : _padding = padding,
        super(labelFormatter: labelFormatter);

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

  ColorScale({this.values = const [], this.colors = const []});

  Color scale(dynamic value) {
    if (values.isEmpty || colors.isEmpty) return Colors.blue;
    final index = values.indexOf(value);
    return index >= 0 ? colors[index % colors.length] : colors[0];
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
